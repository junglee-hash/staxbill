CREATE PROCEDURE [Reporting].[CCM_ReconciliationReport]
--DECLARE
	@AccountId BIGINT = 30417
	,@StartDate DATETIME = '20200205'
	,@EndDate DATETIME = '20210518'

AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

--Temp table to customer details
SELECT * INTO #CustomerData
FROM BasicCustomerDataByAccount(@AccountId)

DECLARE @TimezoneId INT
SELECT @TimezoneId = TimezoneId
		,@StartDate = dbo.fn_GetUtcTime(@StartDate,TimezoneId)			      
		,@EndDate = dbo.fn_GetUtcTime (@EndDate,TimezoneId)
FROM AccountPreference
WHERE Id = @AccountId

CREATE TABLE #ReconciliationTransactions
(
Id BIGINT NOT NULL
,TransactionTypeId INT NOT NULL
,TransactionType VARCHAR(50) NOT NULL
,Description NVARCHAR(2000) NULL
,Currency VARCHAR(50) NOT NULL
,EffectiveTimestamp DATETIME NOT NULL
,EffectiveTimestampUTC DATETIME NOT NULL
,CustomerId BIGINT NOT NULL
,Amount MONEY NOT NULL
)


INSERT INTO #ReconciliationTransactions (Id, TransactionTypeId, TransactionType, Description,Currency,EffectiveTimestamp,EffectiveTimestampUTC,CustomerId, Amount)
SELECT
	t.Id
	,t.TransactionTypeId
	,tt.Name as TransactionType
	,t.Description
	,cc.IsoName as Currency
	,EffectiveTimestamp.TimezoneDateTime as EffectiveTimestamp
	,t.EffectiveTimestamp as EffectiveTimestampUTC
	,t.CustomerId
	,t.Amount
FROM [Transaction] t
INNER JOIN Lookup.TransactionType tt ON tt.Id = t.TransactionTypeId
INNER JOIN Lookup.Currency cc ON cc.Id = t.CurrencyId
CROSS APPLY Timezone.tvf_GetTimezoneTime(@TimezoneId, t.EffectiveTimestamp) EffectiveTimestamp
WHERE t.AccountId = @AccountId
AND t.EffectiveTimestamp >= @StartDate
AND t.EffectiveTimestamp < @EndDate
AND t.Amount <> 0
--Exclude all earning transactions and opening balances
AND t.TransactionTypeId NOT IN (6,9,23,27,    16,19)

CREATE TABLE #NormalTransactions (
	[Transaction ID] VARCHAR(255)
	,TransactionId BIGINT
	,CustomerId BIGINT
	,[Transaction Type] VARCHAR(50)
	,TransactionTypeId INT
	,[Transaction Name] NVARCHAR(2000)
	,[Transaction Reference] NVARCHAR(500)
	,[Transaction Description] NVARCHAR(2000)
	,[ProductCode] NVARCHAR(1000)
	,[Ledger Date] DATETIME
	,EffectiveTimestampUTC DATETIME
	,[Associated ID] VARCHAR(255)
	,[GL Code] NVARCHAR(255)
	,Currency VARCHAR(10)
	,Amount MONEY
	,[Payment Reconciliation Id] VARCHAR(2000)
	,[Payment Activity ID] VARCHAR(1000)
	,[Payment Activity Associated ID] VARCHAR(1000)
	,[Invoice ID] VARCHAR(1000)
	,InvoiceId BIGINT NULL
	,[Invoice Number] VARCHAR(1000)
	,WasFullyPaid TINYINT
	,EarnedRevAccount VARCHAR(100)
)

--Charges
INSERT INTO #NormalTransactions
SELECT
	CONVERT(VARCHAR,rt.Id) as [Transaction ID]
	,rt.Id
	,rt.CustomerId
	,rt.TransactionType as [Transaction Type]
	,rt.TransactionTypeId
	,ch.Name as [Transaction Name]
	,'' as [Transaction Reference] 
	,COALESCE(rt.Description,'') as [Transaction Description]
	,COALESCE(sp.PlanProductCode,pr.Code) as ProductCode
	,rt.EffectiveTimestamp as [Ledger Date]
	,rt.EffectiveTimestampUTC
	,'' as [Associated ID]
	,COALESCE(gl.Code,'') as [GL Code]
	,rt.Currency as Currency
	,rt.Amount
	,'' as [Payment Reconciliation ID]
	,'' as [Payment Activity ID]
	,'' as [Payment Activity Associated ID]
	,CONVERT(VARCHAR,i.Id) as [Invoice ID]
	,i.Id AS InvoiceId
	,CONVERT(VARCHAR,i.InvoiceNumber) as [Invoice Number]
	,NULL AS WasFullyPaid
	,NULL AS EarnedRevAccount
FROM #ReconciliationTransactions rt
INNER JOIN Charge ch ON ch.Id = rt.Id
INNER JOIN Invoice i ON i.Id = ch.InvoiceId
LEFT JOIN GlCode gl ON gl.Id = ch.GLCodeId

LEFT JOIN SubscriptionProductCharge spc ON spc.Id = ch.Id
LEFT JOIN SubscriptionProduct sp ON sp.Id = spc.SubscriptionProductId

LEFT JOIN PurchaseCharge pc ON pc.Id = ch.Id
LEFT JOIN Purchase pu ON pu.Id = pc.PurchaseId
LEFT JOIN Product pr ON pr.Id = pu.ProductId

--Reversals
INSERT INTO #NormalTransactions
SELECT
	CONVERT(VARCHAR,rt.Id) as [Transaction ID]
	,rt.Id
	,rt.CustomerId
	,rt.TransactionType as [Transaction Type]
	,rt.TransactionTypeId
	,ch.Name as [Transaction Name]
	,'' as [Transaction Reference] 
	,COALESCE(rt.Description,'') as [Transaction Description]
	,COALESCE(sp.PlanProductCode,pr.Code) as ProductCode
	,rt.EffectiveTimestamp as [Ledger Date]
	,rt.EffectiveTimestampUTC
	,'' as [Associated ID]
	,COALESCE(gl.Code,'') as [GL Code]
	,rt.Currency as Currency
	,rt.Amount
	,'' as [Payment Reconciliation ID]
	,'' as [Payment Activity ID]
	,'' as [Payment Activity Associated ID]
	,CONVERT(VARCHAR,i.Id) as [Invoice ID]
	,i.Id AS InvoiceId
	,CONVERT(VARCHAR,i.InvoiceNumber) as [Invoice Number]
	,NULL as WasFullyPaid
	,COALESCE(ppfcf.DefaultStringValue, pcf.DefaultStringValue) as EarnedRevAccount
FROM #ReconciliationTransactions rt
INNER JOIN ReverseCharge rc ON rc.Id = rt.Id
INNER JOIN Charge ch ON ch.Id = rc.OriginalChargeId
INNER JOIN Invoice i ON i.Id = ch.InvoiceId
LEFT JOIN GlCode gl ON gl.Id = ch.GLCodeId

LEFT JOIN SubscriptionProductCharge spc ON spc.Id = ch.Id
LEFT JOIN SubscriptionProduct sp ON sp.Id = spc.SubscriptionProductId
LEFT OUTER JOIN PlanProductFrequencyCustomField ppfcf 
	ON ppfcf.PlanProductUniqueId = sp.PlanProductUniqueId

LEFT JOIN PurchaseCharge pc ON pc.Id = ch.Id
LEFT JOIN Purchase pu ON pu.Id = pc.PurchaseId
LEFT JOIN Product pr ON pr.Id = pu.ProductId

LEFT OUTER JOIN ProductCustomField pcf 
	ON pcf.ProductId = pu.ProductId
--Custom Fields
INNER JOIN CustomField cf
	ON cf.Id = COALESCE(ppfcf.CustomFieldId,pcf.CustomFieldId)
	AND cf.[Key] = 'EarnedRev'
	AND cf.AccountId = @AccountId

--Discounts
INSERT INTO #NormalTransactions
SELECT
	CONVERT(VARCHAR,rt.Id) as [Transaction ID]
	,rt.Id
	,rt.CustomerId
	,rt.TransactionType as [Transaction Type]
	,rt.TransactionTypeId
	,ch.Name as [Transaction Name]
	,'' as [Transaction Reference] 
	,COALESCE(rt.Description,'') as [Transaction Description]
	,COALESCE(sp.PlanProductCode,pr.Code) as ProductCode
	,rt.EffectiveTimestamp as [Ledger Date]
	,rt.EffectiveTimestampUTC
	,CONVERT(VARCHAR,d.ChargeId) as [Associated ID]
	,COALESCE(gl.Code,'') as [GL Code]
	,rt.Currency as Currency
	,rt.Amount
	,'' as [Payment Reconciliation ID]
	,'' as [Payment Activity ID]
	,'' as [Payment Activity Associated ID]
	,CONVERT(VARCHAR,i.Id) as [Invoice ID]
	,i.Id AS InvoiceId
	,CONVERT(VARCHAR,i.InvoiceNumber) as [Invoice Number]
	,NULL as WasFullyPaid
	,NULL AS EarnedRevAccount
FROM #ReconciliationTransactions rt
INNER JOIN Discount d ON d.Id = rt.Id
INNER JOIN Charge ch ON ch.Id = d.ChargeId
INNER JOIN Invoice i ON i.Id = ch.InvoiceId
LEFT JOIN GlCode gl ON gl.Id = ch.GLCodeId

LEFT JOIN SubscriptionProductCharge spc ON spc.Id = ch.Id
LEFT JOIN SubscriptionProduct sp ON sp.Id = spc.SubscriptionProductId

LEFT JOIN PurchaseCharge pc ON pc.Id = ch.Id
LEFT JOIN Purchase pu ON pu.Id = pc.PurchaseId
LEFT JOIN Product pr ON pr.Id = pu.ProductId

--Reverse Discounts with discount ledger
INSERT INTO #NormalTransactions
SELECT
	CONVERT(VARCHAR,rt.Id) as [Transaction ID]
	,rt.Id
	,rt.CustomerId
	,rt.TransactionType as [Transaction Type]
	,rt.TransactionTypeId
	,ch.Name as [Transaction Name]
	,'' as [Transaction Reference] 
	,COALESCE(rt.Description,'') as [Transaction Description]
	,COALESCE(sp.PlanProductCode,pr.Code) as ProductCode
	,rt.EffectiveTimestamp as [Ledger Date]
	,rt.EffectiveTimestampUTC
	,CONVERT(VARCHAR,d.ChargeId) as [Associated ID]
	,COALESCE(gl.Code,'') as [GL Code]
	,rt.Currency as Currency
	,rt.Amount
	,'' as [Payment Reconciliation ID]
	,'' as [Payment Activity ID]
	,'' as [Payment Activity Associated ID]
	,CONVERT(VARCHAR,i.Id) as [Invoice ID]
	,i.Id AS InvoiceId
	,CONVERT(VARCHAR,i.InvoiceNumber) as [Invoice Number]
	,NULL as WasFullyPaid
	,pcf.DefaultStringValue AS EarnedRevAccount
FROM #ReconciliationTransactions rt
INNER JOIN ReverseDiscount rd ON rd.Id = rt.Id
INNER JOIN Discount d ON d.Id = rd.OriginalDiscountId
INNER JOIN Charge ch ON ch.Id = d.ChargeId
INNER JOIN Invoice i ON i.Id = ch.InvoiceId
LEFT JOIN GlCode gl ON gl.Id = ch.GLCodeId

LEFT JOIN SubscriptionProductCharge spc ON spc.Id = ch.Id
LEFT JOIN SubscriptionProduct sp ON sp.Id = spc.SubscriptionProductId

LEFT JOIN PurchaseCharge pc ON pc.Id = ch.Id
LEFT JOIN Purchase pu ON pu.Id = pc.PurchaseId
LEFT JOIN Product pr ON pr.Id = pu.ProductId
INNER JOIN ProductCustomField pcf ON pcf.ProductId = COALESCE(sp.ProductId,pu.ProductId)
INNER JOIN CustomField cf ON cf.Id = pcf.CustomFieldId
WHERE cf.[Key] = 'DiscountLedger'

--Reverse Discounts without discount ledger
INSERT INTO #NormalTransactions
SELECT
	CONVERT(VARCHAR,rt.Id) as [Transaction ID]
	,rt.Id
	,rt.CustomerId
	,rt.TransactionType as [Transaction Type]
	,rt.TransactionTypeId
	,ch.Name as [Transaction Name]
	,'' as [Transaction Reference] 
	,COALESCE(rt.Description,'') as [Transaction Description]
	,COALESCE(sp.PlanProductCode,pr.Code) as ProductCode
	,rt.EffectiveTimestamp as [Ledger Date]
	,rt.EffectiveTimestampUTC
	,CONVERT(VARCHAR,d.ChargeId) as [Associated ID]
	,COALESCE(gl.Code,'') as [GL Code]
	,rt.Currency as Currency
	,rt.Amount
	,'' as [Payment Reconciliation ID]
	,'' as [Payment Activity ID]
	,'' as [Payment Activity Associated ID]
	,CONVERT(VARCHAR,i.Id) as [Invoice ID]
	,i.Id AS InvoiceId
	,CONVERT(VARCHAR,i.InvoiceNumber) as [Invoice Number]
	,NULL as WasFullyPaid
	,ads.[Value] AS EarnedRevAccount
FROM #ReconciliationTransactions rt
INNER JOIN ReverseDiscount rd ON rd.Id = rt.Id
INNER JOIN Discount d ON d.Id = rd.OriginalDiscountId
INNER JOIN Charge ch ON ch.Id = d.ChargeId
INNER JOIN Invoice i ON i.Id = ch.InvoiceId
INNER JOIN AccountDisplaySetting ads ON ads.AccountId = @AccountId AND ads.CategoryId = 4 AND ads.LookupId = 6 --Earned discount
LEFT JOIN GlCode gl ON gl.Id = ch.GLCodeId

LEFT JOIN SubscriptionProductCharge spc ON spc.Id = ch.Id
LEFT JOIN SubscriptionProduct sp ON sp.Id = spc.SubscriptionProductId

LEFT JOIN PurchaseCharge pc ON pc.Id = ch.Id
LEFT JOIN Purchase pu ON pu.Id = pc.PurchaseId
LEFT JOIN Product pr ON pr.Id = pu.ProductId
WHERE NOT EXISTS (
	SELECT 1
	FROM #NormalTransactions nt
	WHERE nt.TransactionId = rt.Id
)

--Payments
INSERT INTO #NormalTransactions
SELECT
	CONVERT(VARCHAR,rt.Id) as [Transaction ID]
	,rt.Id
	,rt.CustomerId
	,rt.TransactionType as [Transaction Type]
	,rt.TransactionTypeId
	,'' as [Transaction Name]
	,COALESCE(p.Reference,'') as [Transaction Reference]
	,COALESCE(rt.Description,'') as [Transaction Description]
	,'' as ProductCode
	,rt.EffectiveTimestamp as [Ledger Date]
	,rt.EffectiveTimestampUTC
	,'' as [Associated ID]
	,'' as [GL Code]
	,rt.Currency as Currency
	,rt.Amount
	,ISNULL(CONVERT(NVARCHAR(50),paj.ReconciliationId),'') as [Payment Reconciliation ID]
	,CONVERT(VARCHAR,p.PaymentActivityJournalId) as [Payment Activity ID]
	,'' as [Payment Activity Associated ID]
	,invNumb.InvoiceIds as [Invoice ID]
	,NULL AS InvoiceId
	,invNumb.InvoiceNumbers as [Invoice Number]
	,NULL as WasFullyPaid
	,NULL AS EarnedRevAccount
FROM #ReconciliationTransactions rt
INNER JOIN Payment p ON p.Id = rt.Id
INNER JOIN PaymentActivityJournal paj ON paj.Id = p.PaymentActivityJournalId
LEFT JOIN (SELECT 
	PaymentId
	,SUBSTRING(STUFF(
		(SELECT ', ' + CONVERT(VARCHAR(20),i.InvoiceNumber)
		FROM PaymentNote pn2
		INNER JOIN Invoice i ON pn2.InvoiceId = i.Id
		WHERE pn2.PaymentId = pn.PaymentId
		ORDER BY InvoiceNumber
			FOR XML PATH('')),1,1,''),1,1000) AS InvoiceNumbers
	,SUBSTRING(STUFF(
		(SELECT ', ' + CONVERT(VARCHAR(20),i.Id)
		FROM PaymentNote pn2
		INNER JOIN Invoice i ON pn2.InvoiceId = i.Id
		WHERE pn2.PaymentId = pn.PaymentId
		ORDER BY i.Id
			FOR XML PATH('')),1,1,''),1,1000) AS InvoiceIds
	FROM PaymentNote pn
	GROUP BY PaymentId) invNumb on invNumb.PaymentId = rt.Id

--Refunds
INSERT INTO #NormalTransactions
SELECT
	CONVERT(VARCHAR,rt.Id) as [Transaction ID]
	,rt.Id
	,rt.CustomerId
	,rt.TransactionType as [Transaction Type]
	,rt.TransactionTypeId
	,'' as [Transaction Name]
	,COALESCE(r.Reference,'') as [Transaction Reference]
	,COALESCE(rt.Description,'') as [Transaction Description]
	,'' as ProductCode
	,rt.EffectiveTimestamp as [Ledger Date]
	,rt.EffectiveTimestampUTC
	,CONVERT(VARCHAR,r.OriginalPaymentId) as [Associated ID]
	,'' as [GL Code]
	,rt.Currency as Currency
	,rt.Amount
	,ISNULL(CONVERT(NVARCHAR(50),paj.ReconciliationId),'') as [Payment Reconciliation ID]
	,CONVERT(VARCHAR,r.PaymentActivityJournalId) as [Payment Activity ID]
	,CONVERT(VARCHAR,r.OriginalPaymentId) as [Payment Activity Associated ID]
	,invNumb.InvoiceIds as [Invoice ID]
	,NULL AS InvoiceId
	,invNumb.InvoiceNumbers as [Invoice Number]
	,NULL as WasFullyPaid
	,NULL AS EarnedRevAccount
FROM #ReconciliationTransactions rt
INNER JOIN Refund r ON r.Id = rt.Id
INNER JOIN Payment p ON p.Id = r.OriginalPaymentId
INNER JOIN PaymentActivityJournal paj ON paj.Id = r.PaymentActivityJournalId
LEFT JOIN (SELECT 
	RefundId
	,SUBSTRING(STUFF(
		(SELECT ', ' + CONVERT(VARCHAR(20),i.InvoiceNumber)
		FROM RefundNote pn2
		INNER JOIN Invoice i ON pn2.InvoiceId = i.Id
		WHERE pn2.RefundId = pn.RefundId
		ORDER BY InvoiceNumber
			FOR XML PATH('')),1,1,''),1,1000) AS InvoiceNumbers
	,SUBSTRING(STUFF(
		(SELECT ', ' + CONVERT(VARCHAR(20),i.Id)
		FROM RefundNote pn2
		INNER JOIN Invoice i ON pn2.InvoiceId = i.Id
		WHERE pn2.RefundId = pn.RefundId
		ORDER BY i.Id
			FOR XML PATH('')),1,1,''),1,1000) AS InvoiceIds
	FROM RefundNote pn
	GROUP BY RefundId) invNumb on invNumb.RefundId = rt.Id

--Determine WasFullyPaid
--Potential optimization is to only do this for reverse type transactions
UPDATE nt
SET WasFullyPaid = CASE WHEN 
		--Was Previously Paid
		(ijo.SumOfPayments - ijo.SumOfRefunds + ijo.SumOfCreditNotes = ijo.SumOfCharges - ijo.SumOfDiscounts AND (ijo.SumOfPayments > ijo.SumOfRefunds OR ijo.SumOfCharges = ijo.SumOfDiscounts) AND ijo.OutstandingBalance = 0) 
		--Is paid by reversal
		OR (ij.SumOfPayments - ij.SumOfRefunds + ij.SumOfCreditNotes = ij.SumOfCharges - ij.SumOfDiscounts AND (ij.SumOfPayments > ij.SumOfRefunds OR ij.SumOfCharges = ij.SumOfDiscounts) AND ij.OutstandingBalance = 0)
		THEN 1 ELSE 0 END
FROM #NormalTransactions nt
INNER JOIN Invoice i ON i.Id = nt.InvoiceId
LEFT JOIN InvoiceJournal ij ON ij.InvoiceId = i.Id AND nt.EffectiveTimestampUTC = ij.CreatedTimestamp
LEFT JOIN InvoiceJournal ijo ON ijo.Id = (
	SELECT TOP 1 ijj.Id
	FROM InvoiceJournal ijj
	WHERE ijj.CreatedTimestamp < nt.EffectiveTimestampUTC
	AND ijj.InvoiceId = i.Id
	ORDER BY ijj.CreatedTimestamp DESC
)


CREATE TABLE #Report (
	[Fusebill ID] BIGINT
	,[Transaction ID] VARCHAR(255)
	,[Associated ID] VARCHAR(255)
	,[Transaction Type] VARCHAR(50)
	,[Transaction Name] NVARCHAR(2000)
	,[Transaction Reference] NVARCHAR(500)
	,[Transaction Description] NVARCHAR(2000)
	,[ProductCode] NVARCHAR(1000)
	,[GL Code] NVARCHAR(255)
	,[Ledger Date] NVARCHAR(255)
	,[Currency] VARCHAR(10)
	,[112111] MONEY
	,[102600] MONEY
	,[Recognized Revenue] MONEY
	,[240111] MONEY
	,[Taxes Payable] MONEY
	,[509201] MONEY
	,[Deferred Discount] MONEY
	,[Write Off] MONEY
	,[Credit] MONEY
	,[Opening Balance] MONEY
	,[240112] MONEY
	,[220150] MONEY
	,[414000] MONEY
	,[416000] MONEY
	,[Payment Reconciliation Id] VARCHAR(2000)
	,[Payment Activity ID] VARCHAR(1000)
	,[Payment Activity Associated ID] VARCHAR(1000)
	,[Invoice ID] VARCHAR(1000)
	,[Invoice Number] VARCHAR(1000)
)


INSERT INTO #Report
SELECT 
	fin.CustomerId AS [Fusebill ID]
	,fin.[Transaction ID]
	,fin.[Associated ID]
	,fin.[Transaction Type]
	,fin.[Transaction Name]
	,fin.[Transaction Reference]
	,fin.[Transaction Description]
	,fin.ProductCode as [ProductCode]
	,fin.[GL Code]
	,FORMAT(fin.[Ledger Date],'yyyy-MM-dd HH:mm:ss','en-US') as [Ledger Date]
	,fin.Currency
	--Taking transaction type ledgers from Lookup.TransactionTypeLedger
	,CASE WHEN fin.TransactionTypeId IN (1,2,4,5,11,15,18,19,20,22,25) THEN fin.Amount WHEN fin.TransactionTypeId IN (3,7,8,10,12,14,16,17,21,24) THEN -fin.Amount ELSE 0 END as [112111]
	,CASE WHEN fin.TransactionTypeId IN (3) THEN fin.Amount WHEN fin.TransactionTypeId IN (4,5,25) THEN -fin.Amount ELSE 0 END as [102600]
	,0 as [Recognized Revenue]
	,CASE WHEN fin.TransactionTypeId IN (6,7,8,27,  3,21,  24) THEN fin.Amount WHEN fin.TransactionTypeId IN (1,2,9,20,26,22, 15,   4,5,25) THEN -fin.Amount ELSE 0 END as [240111]
	,0 as [Taxes Payable]
	,CASE WHEN WasFullyPaid = 1 AND fin.TransactionTypeId IN (15,22) AND EarnedRevAccount = '509201' THEN -fin.Amount ELSE 0 END as [509201]
	,0 [Deferred Discount]
	,0 as [Write Off]
	,0 as [Credit]
	,CASE WHEN fin.TransactionTypeId IN (19) THEN -fin.Amount ELSE 0 END as [Opening Balance]
	,CASE WHEN fin.TransactionTypeId IN (4,5,25) THEN fin.Amount 
		WHEN fin.TransactionTypeId IN (3) OR (fin.TransactionTypeId IN (7,8,24) AND WasFullyPaid = 1) THEN -fin.Amount 
		WHEN fin.TransactionTypeId IN (15,22) AND WasFullyPaid = 1 THEN fin.Amount ELSE 0 END as [240112]
	--Fully paid reversals need to reverse the "recognized" revenue
	,CASE WHEN WasFullyPaid = 1 AND EarnedRevAccount = '220150' THEN 
		CASE WHEN fin.TransactionTypeId IN (7,8,24) THEN fin.Amount
			 WHEN fin.TransactionTypeId IN (15,22) THEN -fin.Amount 
			 ELSE 0 END
		ELSE 0 END as [220150]
	,CASE WHEN WasFullyPaid = 1 AND EarnedRevAccount = '414000' THEN 
		CASE WHEN fin.TransactionTypeId IN (7,8,24) THEN fin.Amount ELSE 0 END 
		ELSE 0 END as [414000]
	,CASE WHEN WasFullyPaid = 1 AND EarnedRevAccount = '416000' THEN 
		CASE WHEN fin.TransactionTypeId IN (7,8,24) THEN fin.Amount ELSE 0 END 
		ELSE 0 END as [416000]
	,LOWER(fin.[Payment Reconciliation Id]) as [Payment Reconciliation Id]
	,fin.[Payment Activity ID]
	,fin.[Payment Activity Associated ID]
	,LTRIM(fin.[Invoice ID]) as [Invoice ID]
	,LTRIM(fin.[Invoice Number]) as [Invoice Number]
FROM #NormalTransactions fin

CREATE TABLE #MadeUpTransactions
(
	TransactionId BIGINT
	,FusebillId BIGINT
	,[EffectiveDate_AccountTimezone] DATETIME
	,EffectiveDateUtc DATETIME
	,TransactionTypeId INT
	,SubscriptionProductId BIGINT
	,PurchaseId BIGINT
	,AllocationType VARCHAR(5)
	,Amount MONEY
	,Description NVARCHAR(2000)
	,Name NVARCHAR(2000)
	,Currency VARCHAR(50)
	,InvoiceId BIGINT
	,InvoiceNumber VARCHAR(1000)
	,PaymentActivityIds VARCHAR(1000)
	,ReconciliationIds VARCHAR(2000)
	,AssociatedPaymentActivityIds VARCHAR(1000)
	,TransactionIds VARCHAR(1000)
	,AccountLedgerName VARCHAR(100)
)


;WITH CTE_InvoiceJournalsSetup AS (
	SELECT 
		'PA' as AllocationType
		,i.AccountId
		,ij.[CreatedTimestamp]
		,ij.InvoiceId
		,i.InvoiceNumber
		,i.Id
		,ij.Id as InvoiceJournalId
		,p.PaymentActivityJournalId
		,paj.ReconciliationId
		,'' as AssociatedPaymentActivityJournalId
		,p.Id as TransactionId
	FROM InvoiceJournal ij
	INNER JOIN Invoice i ON i.Id = ij.InvoiceId AND i.AccountId = @AccountId
	LEFT JOIN PaymentNote pn ON pn.InvoiceId = ij.InvoiceId AND pn.EffectiveTimestamp <= ij.CreatedTimestamp
	LEFT JOIN Payment p ON p.Id = pn.PaymentId
	LEFT JOIN PaymentActivityJournal paj ON paj.Id = p.PaymentActivityJournalId
	LEFT JOIN InvoiceJournal ijo ON ijo.Id = (
		SELECT TOP 1 ijj.Id
		FROM InvoiceJournal ijj
		WHERE ijj.CreatedTimestamp < ij.CreatedTimestamp
		AND ijj.InvoiceId = i.Id
		ORDER BY ijj.CreatedTimestamp DESC
	)
	WHERE (ij.CreatedTimestamp >= @StartDate AND ij.CreatedTimestamp < @EndDate)
	--Journal is paid
	AND ij.SumOfPayments - ij.SumOfRefunds + ij.SumOfCreditNotes = ij.SumOfCharges - ij.SumOfDiscounts AND (ij.SumOfPayments > ij.SumOfRefunds OR ij.SumOfCharges = ij.SumOfDiscounts)
	--Old journal was not paid
	AND (ijo.Id IS NULL OR (ijo.SumOfPayments - ijo.SumOfRefunds + ijo.SumOfCreditNotes != ijo.SumOfCharges  - ij.SumOfDiscounts OR ijo.SumOfPayments = ijo.SumOfRefunds) AND ijo.SumOfCharges != ijo.SumOfDiscounts)
	AND ij.OutstandingBalance = 0

	UNION ALL

	SELECT 
		'RA' as AllocationType
		,i.AccountId
		,ij.[CreatedTimestamp]
		,ij.InvoiceId
		,i.InvoiceNumber
		,i.Id
		,ij.Id as InvoiceJournalId
		,r.PaymentActivityJournalId
		,paj.ReconciliationId
		,pp.PaymentActivityJournalId AS AssociatedPaymentActivityJournalId
		,r.Id as TransactionId
	FROM invoiceJournal ij
	INNER JOIN Invoice i
		ON i.Id = ij.InvoiceId
		AND i.AccountId = @AccountId
	--Refunds returned by this query should correlate to InvoiceIds with an InvoiceJournal that was was previously fully allocated
	CROSS APPLY (
		SELECT TOP 1 SumOfCharges,SumOfPayments,OutstandingBalance,SumOfCreditNotes,SumOfRefunds,SumOfDiscounts
		FROM InvoiceJournal pij
		WHERE pij.InvoiceId = ij.InvoiceId
		AND pij.Id < ij.Id
		ORDER BY pij.Id DESC
	) pfaij
	LEFT JOIN RefundNote rn ON rn.InvoiceId = ij.InvoiceId AND rn.EffectiveTimestamp <= ij.CreatedTimestamp
	LEFT JOIN Refund r ON r.Id = rn.RefundId
	LEFT JOIN PaymentActivityJournal paj ON paj.Id = r.PaymentActivityJournalId
	LEFT JOIN Payment pp ON pp.Id = r.OriginalPaymentId
	WHERE (ij.CreatedTimestamp >= @StartDate AND ij.CreatedTimestamp < @EndDate)
	AND ij.OutstandingBalance <> 0
	AND ij.SumOfRefunds > 0
	AND pfaij.OutstandingBalance = 0
	AND pfaij.SumOfPayments - pfaij.SumOfRefunds + pfaij.SumOfCreditNotes = pfaij.SumOfCharges - ij.SumOfDiscounts AND pfaij.SumOfPayments > pfaij.SumOfRefunds
	)
,CTE_InvoiceJournals AS (
	SELECT
	ij.AllocationType
	,ij.AccountId
	,ij.[CreatedTimestamp]
	,ij.InvoiceId
	,ij.InvoiceNumber
	,ij.Id
	,ij.InvoiceJournalId
	,STUFF(
			(SELECT ', ' + CONVERT(VARCHAR(50),ij2.PaymentActivityJournalId)
			FROM CTE_InvoiceJournalsSetup ij2
			WHERE ij2.InvoiceJournalId = ij.InvoiceJournalId
			ORDER BY ij2.PaymentActivityJournalId
				FOR XML PATH('')),1,1,'') AS PaymentActivityIds
	,STUFF(
			(SELECT ', ' + CONVERT(VARCHAR(50),ij2.ReconciliationId)
			FROM CTE_InvoiceJournalsSetup ij2
			WHERE ij2.InvoiceJournalId = ij.InvoiceJournalId
			ORDER BY ij2.PaymentActivityJournalId
				FOR XML PATH('')),1,1,'') AS ReconciliationIds
	,STUFF(
			(SELECT ', ' + CONVERT(VARCHAR(50),ij2.AssociatedPaymentActivityJournalId)
			FROM CTE_InvoiceJournalsSetup ij2
			WHERE ij2.InvoiceJournalId = ij.InvoiceJournalId
			AND ij2.AssociatedPaymentActivityJournalId != 0
			ORDER BY ij2.PaymentActivityJournalId
				FOR XML PATH('')),1,1,'') AS AssociatedPaymentActivityIds
	,STUFF(
			(SELECT ', ' + CONVERT(VARCHAR(50),ij2.TransactionId)
			FROM CTE_InvoiceJournalsSetup ij2
			WHERE ij2.InvoiceJournalId = ij.InvoiceJournalId
			ORDER BY ij2.TransactionId
				FOR XML PATH('')),1,1,'') AS TransactionIds
	FROM CTE_InvoiceJournalsSetup ij
	GROUP BY 
		ij.AccountId
		,ij.[CreatedTimestamp]
		,ij.InvoiceId
		,ij.InvoiceNumber
		,ij.Id
		,ij.InvoiceJournalId
		,ij.AllocationType
)
--Get the source charge information from those invoices
INSERT INTO #MadeUpTransactions
	SELECT 
		t.Id as TransactionId
		,t.CustomerId as FusebillId
		,[CreatedTimestamp].TimezoneDateTime AS [EffectiveDate_AccountTimezone]
		,ij.CreatedTimestamp as EffectiveDateUTC
		,t.TransactionTypeId
		,spc.SubscriptionProductId
		,pc.PurchaseId
		,ij.AllocationType
		,CASE WHEN ij.AllocationType = 'RA' THEN t.Amount ELSE -t.Amount END as Amount
		,t.Description
		,c.Name
		,cu.IsoName as Currency
		,ij.Id AS InvoiceId
		,ij.InvoiceNumber
		,ISNULL(LTRIM(ij.PaymentActivityIds),'') as PaymentActivityIds
		,ISNULL(LTRIM(ij.ReconciliationIds),'') as ReconciliationIds
		,COALESCE(LTRIM(ij.AssociatedPaymentActivityIds),'') as AssociatedPaymentActivityIds
		,LTRIM(ij.TransactionIds) as TransactionIds
		,NULL as AccountLedgerName
	FROM CTE_InvoiceJournals ij
	INNER JOIN [Charge] c ON c.InvoiceId = ij.InvoiceId
	INNER JOIN [Transaction] t ON t.Id = c.Id
	INNER JOIN Lookup.Currency cu ON cu.Id = t.CurrencyId
	INNER JOIN Lookup.TransactionType ltt ON ltt.Id = t.TransactionTypeId
	CROSS APPLY Timezone.tvf_GetTimezoneTime (@TimezoneId,ij.[CreatedTimestamp]) [CreatedTimestamp]
	LEFT OUTER JOIN [SubscriptionProductCharge] spc ON spc.Id = t.Id
	LEFT OUTER JOIN [PurchaseCharge] pc ON pc.Id = t.Id
	WHERE t.AccountId = @AccountId
	AND t.TransactionTypeId IN (1,19,20)
	AND t.Amount <> 0

UNION

	--Discounts
	SELECT 
		t.Id as TransactionId
		,t.CustomerId as FusebillId
		,[CreatedTimestamp].TimezoneDateTime AS [EffectiveDate_AccountTimezone]
		,ij.CreatedTimestamp as EffectiveDateUTC
		,t.TransactionTypeId
		,spc.SubscriptionProductId
		,pc.PurchaseId
		,ij.AllocationType
		,CASE WHEN ij.AllocationType = 'RA' THEN -t.Amount ELSE t.Amount END as Amount
		,t.Description
		,c.Name
		,cu.IsoName as Currency
		,ij.Id AS InvoiceId
		,ij.InvoiceNumber
		,ISNULL(LTRIM(ij.PaymentActivityIds),'') as PaymentActivityIds
		,ISNULL(LTRIM(ij.ReconciliationIds),'') as ReconciliationIds
		,COALESCE(LTRIM(ij.AssociatedPaymentActivityIds),'') as AssociatedPaymentActivityIds
		,LTRIM(ij.TransactionIds) as TransactionIds
		,ads.Value as AccountLedgerName
	FROM CTE_InvoiceJournals ij
	INNER JOIN [Charge] c ON c.InvoiceId = ij.InvoiceId
	INNER JOIN Discount d ON d.ChargeId = c.Id
	INNER JOIN [Transaction] t ON t.Id = d.Id
	INNER JOIN Lookup.Currency cu ON cu.Id = t.CurrencyId
	INNER JOIN Lookup.TransactionType ltt ON ltt.Id = t.TransactionTypeId
	INNER JOIN AccountDisplaySetting ads ON ads.AccountId = @AccountId AND ads.CategoryId = 4 AND ads.LookupId = 6 --Earned discount
	CROSS APPLY Timezone.tvf_GetTimezoneTime (@TimezoneId,ij.[CreatedTimestamp]) [CreatedTimestamp]
	LEFT OUTER JOIN [SubscriptionProductCharge] spc ON spc.Id = c.Id
	LEFT OUTER JOIN [PurchaseCharge] pc ON pc.Id = c.Id
	WHERE t.AccountId = @AccountId
	AND t.TransactionTypeId IN (14,21)
	AND t.Amount <> 0

;WITH Reversals AS
(
	SELECT
		mt.TransactionId
		,mt.EffectiveDateUtc
		,SUM(t.Amount) as ReversedAmount
	FROM #MadeUpTransactions mt
	INNER JOIN ReverseCharge rc ON rc.OriginalChargeId = mt.TransactionId
	INNER JOIN [Transaction] t ON t.Id = rc.Id
	WHERE
		t.EffectiveTimestamp < mt.EffectiveDateUtc 
	GROUP BY mt.TransactionId, mt.EffectiveDateUtc
)
UPDATE mt
SET mt.Amount = CASE WHEN mt.AllocationType = 'PA' THEN mt.Amount + ft.ReversedAmount ELSE mt.Amount - ft.ReversedAmount END
FROM #MadeUpTransactions mt
INNER JOIN Reversals ft ON ft.TransactionId = mt.TransactionId AND mt.EffectiveDateUtc = ft.EffectiveDateUtc

;WITH ReversalDiscounts AS
(
	SELECT
		mt.TransactionId
		,mt.EffectiveDateUtc
		,SUM(t.Amount) as ReversedAmount
	FROM #MadeUpTransactions mt
	INNER JOIN ReverseDiscount rd ON rd.OriginalDiscountId = mt.TransactionId
	INNER JOIN [Transaction] t ON t.Id = rd.Id
	WHERE
		t.EffectiveTimestamp < mt.EffectiveDateUtc 
	GROUP BY mt.TransactionId, mt.EffectiveDateUtc
)
UPDATE mt
SET mt.Amount = CASE WHEN mt.AllocationType = 'RA' THEN mt.Amount + ft.ReversedAmount ELSE mt.Amount - ft.ReversedAmount END
FROM #MadeUpTransactions mt
INNER JOIN ReversalDiscounts ft ON ft.TransactionId = mt.TransactionId AND mt.EffectiveDateUtc = ft.EffectiveDateUtc

--Override account ledger for custom field provided ledgers
UPDATE mt
SET mt.AccountLedgerName = COALESCE(ppfcf.DefaultStringValue, pcf.DefaultStringValue)
FROM #MadeUpTransactions mt
--SubscriptionProduct Joins
	LEFT OUTER JOIN SubscriptionProduct sp ON sp.Id = mt.SubscriptionProductId
	LEFT OUTER JOIN PlanProductFrequencyCustomField ppfcf 
		ON ppfcf.PlanProductUniqueId = sp.PlanProductUniqueId
	--Purchase Joins
	LEFT OUTER JOIN Purchase pu ON pu.Id = mt.PurchaseId
	LEFT OUTER JOIN Product pr ON pr.Id = COALESCE(pu.ProductId,sp.ProductId)
	LEFT OUTER JOIN GLCode gl ON gl.Id = pr.GLCodeId
	LEFT OUTER JOIN ProductCustomField pcf 
		ON pcf.ProductId = pu.ProductId
	--Custom Fields
	LEFT OUTER JOIN CustomField cf
		ON cf.Id = COALESCE(ppfcf.CustomFieldId,pcf.CustomFieldId)
		AND cf.[Key] = CASE WHEN TransactionTypeId IN (14,21) THEN 'DiscountLedger' ELSE 'EarnedRev' END
		AND cf.AccountId = @AccountId
	WHERE cf.Id IS NOT NULL
		AND mt.Amount <> 0

;WITH CTE_CustomFields AS (
	SELECT
		t.FusebillId as [Fusebill ID]
		,CASE WHEN t.TransactionIds IS NULL THEN CONVERT(VARCHAR,t.InvoiceNumber) ELSE  SUBSTRING(CONVERT(VARCHAR,t.InvoiceNumber) + '-' + LTRIM(t.TransactionIds),1,255) END as [Transaction ID]
		,t.TransactionId AS [Associated ID]
		,'Paid for Sales' + CASE WHEN t.AllocationType = 'RA' THEN ' Refund' ELSE '' END   AS [Transaction Type]
		,t.Name AS [Transaction Name]
		,'' AS [Transaction Reference]
		,t.Description AS [Transaction Description]
		,COALESCE(sp.PlanProductCode,pr.Code) AS [ProductCode]
		,gl.Code AS [GL Code]
		,FORMAT(t.EffectiveDate_AccountTimezone,'yyyy-MM-dd HH:mm:ss','en-US') AS [Ledger Date]
		,t.Currency AS [Currency]
		,0 AS [112111]
		,0 AS [102600]
		,0 AS [Recognized Revenue]
		,0 AS [240111]
		,0 AS [Taxes Payable]
		,CASE WHEN t.AccountLedgerName = '509201' THEN t.Amount ELSE 0 END AS [509201]
		,0 AS [Deferred Discount]
		,0 AS [Write Off]
		,0 AS [Credit]
		,0 AS [Opening Balance]
		--Hard coded the deferred revenue account (unallocated manna) for simplicity
		,-t.Amount AS [240112]
		--Credit to earned revenue
		,CASE WHEN t.AccountLedgerName = '220150' THEN t.Amount ELSE 0 END AS [220150]
		,CASE WHEN t.AccountLedgerName = '414000' THEN t.Amount ELSE 0 END AS [414000]
		,CASE WHEN t.AccountLedgerName = '416000' THEN t.Amount ELSE 0 END AS [416000]
		,LOWER(t.ReconciliationIds) AS [Payment Reconciliation Id]
		,t.PaymentActivityIds AS [Payment Activity ID]
		,t.AssociatedPaymentActivityIds AS [Payment Activity Associated ID]
		,CONVERT(VARCHAR,t.InvoiceId) AS [Invoice ID]
		,t.InvoiceNumber AS [Invoice Number]
	FROM #MadeUpTransactions t
	--SubscriptionProduct Joins
	LEFT OUTER JOIN SubscriptionProduct sp ON sp.Id = t.SubscriptionProductId
	----Purchase Joins
	LEFT OUTER JOIN Purchase pu ON pu.Id = t.PurchaseId
	LEFT OUTER JOIN Product pr ON pr.Id = COALESCE(pu.ProductId,sp.ProductId)
	LEFT OUTER JOIN GLCode gl ON gl.Id = pr.GLCodeId
	WHERE 
		t.Amount <> 0
	)
INSERT INTO #Report
SELECT
	*
FROM CTE_CustomFields cf

SELECT 
	r.*
	,cd.[Customer ID]
	,cd.[Customer First Name]
	,cd.[Customer Last Name]
	,cd.[Customer Company Name]
FROM #Report r
INNER JOIN #CustomerData cd ON cd.[Fusebill ID] = r.[Fusebill ID]
ORDER BY [Ledger Date], r.[Transaction Type], r.[Associated ID]

DROP TABLE #CustomerData
DROP TABLE #ReconciliationTransactions
DROP TABLE #NormalTransactions
DROP TABLE #MadeUpTransactions
DROP TABLE #Report

GO

