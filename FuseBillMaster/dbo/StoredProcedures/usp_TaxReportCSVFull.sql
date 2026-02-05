

CREATE PROCEDURE [dbo].[usp_TaxReportCSVFull]
@AccountId BIGINT 
,@StartDate DATETIME
,@EndDate DATETIME
,@CurrencyId BIGINT = 1

AS

SET TRANSACTION ISOLATION LEVEL SNAPSHOT

IF @EndDate IS NULL
	SET @EndDate = GETUTCDATE()
IF @StartDate IS NULL
    SET @StartDate = DATEADD(MONTH,-1,GETUTCDATE())

DECLARE @TimezoneId BIGINT
SELECT @TimezoneId = TimezoneId FROM AccountPreference WHERE Id = @AccountId

--Bring in Customer details from function
SELECT * INTO #CustomerData
FROM dbo.FullCustomerDataWithShippingByAccount(@AccountId,@CurrencyId,@EndDate)

--Full transaction dataset for use in CTEs and Reversal/Discount Left Joins
SELECT 
t.Id
,t.Amount
,ltt.Name AS TransactionType
,t.Description
,t.EffectiveTimestamp
INTO #FullTransactionData
FROM [Transaction] t
INNER JOIN lookup.TransactionType ltt on t.TransactionTypeId = ltt.Id 
INNER JOIN lookup.Currency lc on t.CurrencyId = lc.Id 
WHERE
	t.AccountId = @AccountId
	AND t.CurrencyId = @CurrencyId
	AND t.TransactionTypeId NOT IN (3,4,5,6,23,26,27)

CREATE NONCLUSTERED INDEX [IX_Temp_FullTransactionData_Id_Amount]
ON [#FullTransactionData] ([Id])
INCLUDE ([Amount])

--Filtered transaction dataset to use as anchor base data
SELECT 
t.Id
,t.AccountId
,t.Amount
,t.EffectiveTimestamp
,t.CustomerId
,t.TransactionTypeId
,ltt.Name AS TransactionType
,ARBalanceMultiplier
,@TimezoneId as TimezoneId
,lc.IsoName
,CASE WHEN t.TransactionTypeId = 12 THEN t.Amount ELSE 0 END AS TaxesPayableDebit
,CASE WHEN t.TransactionTypeId IN (11,30) THEN t.Amount ELSE 0 END AS TaxesPayableCredit
INTO #FilteredTransactionData
FROM [Transaction] t
INNER JOIN AccountPreference ap on t.AccountId = ap.Id
INNER JOIN lookup.TransactionType ltt on t.TransactionTypeId = ltt.Id 
INNER JOIN lookup.Currency lc on t.CurrencyId = lc.Id 
WHERE
	t.AccountId = @AccountId 
	AND t.EffectiveTimestamp >= @StartDate 
	AND t.EffectiveTimestamp < @EndDate 
	AND t.TransactionTypeId IN (11,12,30)
	AND t.CurrencyId = @CurrencyId

;WITH JournalAtReport AS (
	SELECT MAX(Id) as Id, PaymentScheduleId
	FROM PaymentScheduleJournal
	WHERE CreatedTimestamp <= @EndDate
	GROUP BY PaymentScheduleId)

,DiscountAmounts AS (
	SELECT SUM(t.Amount) as DiscountTotal, dis.ChargeId
	FROM Discount dis
	INNER JOIN #FullTransactionData t 
	ON dis.Id = t.Id
	GROUP BY dis.ChargeId)

,ReverseDiscountAmounts AS (
	SELECT SUM(t.Amount) as ReverseDiscountTotal, dis.ReverseChargeId
	FROM ReverseDiscount dis
	INNER JOIN #FullTransactionData t 
	ON dis.Id = t.Id
	GROUP BY dis.ReverseChargeId)

,ReversalAmounts AS (
	SELECT SUM(t.Amount) as ReversalTotal, rc.OriginalChargeId
	FROM ReverseCharge rc
	INNER JOIN #FullTransactionData t 
	ON rc.Id = t.Id
	GROUP BY rc.OriginalChargeId)

--Main query union
SELECT *
INTO #Results
FROM (
	--purchases void reversals
	SELECT
		t.id as [Transaction ID],
		t.TransactionType as [Tax Charge Type (Tax Charge or Tax Reversal)],
		convert(datetime,dbo.fn_GetTimezoneTime(t.EffectiveTimestamp,t.TimezoneId )) as [Tax Effective Date],
		ch.Id [Source Charge Id],
		rcht.TransactionType as [Source Charge Transaction Type],
		ch.Name as [Source Charge Name],
		ISNULL(rcht.[Description], '') as [Source Charge Description],
		'' as [Source Charge Plan Code],
		'' as [Source Charge Product Code],
		ISNULL(gl.Name, '') as [Source Charge GL Code],
		'' as [Source Charge Subscription ID],
		pc.Id as [Source Charge Purchase ID],
		convert(datetime,dbo.fn_GetTimezoneTime(rcht.EffectiveTimestamp,t.TimezoneId )) as [Source Charge Posted Date],
		'' as [Source Charge Service Start],
		'' as [Source Charge Service End],
		i.Id as [Invoice ID],
		i.InvoiceNumber as [Invoice Number],
		InvoiceStatusAtTime.Name as [Invoice Status At Report End Date],
		CurrentInvoiceStatus.Name as [Current Invoice Status],
		convert(datetime,dbo.fn_GetTimezoneTime(psj2.CreatedTimestamp,t.TimezoneId )) as [Last Invoice Status Date],
		t.IsoName as [Currency],
		-rch.ReversalTotal as [Source Charge Original Amount],
		ISNULL(ReverseDiscountAmounts.ReverseDiscountTotal, 0) as [Source Charge Original Discount Amount],
		-rch.ReversalTotal + ISNULL(ReverseDiscountAmounts.ReverseDiscountTotal, 0) as [Source Charge Net Amount at Report Date], -- source charge - any reversals
		t.Amount* t.ARBalanceMultiplier as [Tax Amount],
		tax.TaxRuleId as [Tax Rule ID],
		taxr.Name as [Tax Name],
		taxr.Description as [Tax Description],
		ISNULL(taxr.RegistrationCode, '') as [Tax Code],
		taxr.TaxCode as [Unique Tax Code],
		cast(taxr.Percentage  as float) as [Tax Percentage],	
		t.TaxesPayableDebit as [Taxes Payable Debit],
		t.TaxesPayableCredit as [Taxes Payable Credit],
		t.CustomerId
	FROM #FilteredTransactionData t
		INNER JOIN VoidReverseTax vtx ON vtx.Id = t.Id
		INNER JOIN ReverseTax rtax on vtx.OriginalReverseTaxId = rtax.Id
		INNER JOIN Tax tax on rtax.OriginalTaxId = tax.Id
		INNER JOIN TaxRule taxr on tax.TaxRuleId = taxr.Id 
		INNER JOIN Charge ch on tax.ChargeId = ch.Id
		INNER JOIN ReversalAmounts rch on rch.OriginalChargeId = ch.Id
		INNER JOIN #FullTransactionData rcht on rcht.Id = ch.Id
		LEFT OUTER JOIN GLCode gl on gl.Id = ch.GLCodeId
		INNER JOIN Invoice i on i.Id = ch.InvoiceId
		INNER JOIN PurchaseCharge pc on ch.Id = pc.Id
		LEFT OUTER JOIN ReverseDiscountAmounts on ReverseDiscountAmounts.ReverseChargeId = ch.Id
		LEFT OUTER JOIN PaymentSchedule ps on i.Id = ps.InvoiceId
		LEFT OUTER JOIN JournalAtReport jj on ps.Id = jj.PaymentScheduleId
		LEFT OUTER JOIN PaymentScheduleJournal psj1 on psj1.Id = jj.Id
		LEFT OUTER JOIN PaymentScheduleJournal psj2 on ps.Id = psj2.PaymentScheduleId AND psj2.IsActive = 1
		INNER JOIN Lookup.InvoiceStatus InvoiceStatusAtTime on InvoiceStatusAtTime.Id = psj1.StatusId
		INNER JOIN Lookup.InvoiceStatus CurrentInvoiceStatus on CurrentInvoiceStatus.Id = psj2.StatusId
	WHERE t.TransactionTypeId = 30

	UNION ALL

	--purchases reversals
	SELECT
		t.id as [Transaction ID],
		t.TransactionType as [Tax Charge Type (Tax Charge or Tax Reversal)],
		convert(datetime,dbo.fn_GetTimezoneTime(t.EffectiveTimestamp,t.TimezoneId )) as [Tax Effective Date],
		ch.Id [Source Charge Id],
		rcht.TransactionType as [Source Charge Transaction Type],
		ch.Name as [Source Charge Name],
		ISNULL(rcht.[Description], '') as [Source Charge Description],
		'' as [Source Charge Plan Code],
		'' as [Source Charge Product Code],
		ISNULL(gl.Name, '') as [Source Charge GL Code],
		'' as [Source Charge Subscription ID],
		pc.Id as [Source Charge Purchase ID],
		convert(datetime,dbo.fn_GetTimezoneTime(rcht.EffectiveTimestamp,t.TimezoneId )) as [Source Charge Posted Date],
		'' as [Source Charge Service Start],
		'' as [Source Charge Service End],
		i.Id as [Invoice ID],
		i.InvoiceNumber as [Invoice Number],
		InvoiceStatusAtTime.Name as [Invoice Status At Report End Date],
		CurrentInvoiceStatus.Name as [Current Invoice Status],
		convert(datetime,dbo.fn_GetTimezoneTime(psj2.CreatedTimestamp,t.TimezoneId )) as [Last Invoice Status Date],
		t.IsoName as [Currency],
		-rch.ReversalTotal as [Source Charge Original Amount],
		ISNULL(ReverseDiscountAmounts.ReverseDiscountTotal, 0) as [Source Charge Original Discount Amount],
		-rch.ReversalTotal + ISNULL(ReverseDiscountAmounts.ReverseDiscountTotal, 0) as [Source Charge Net Amount at Report Date], -- source charge - any reversals
		t.Amount* t.ARBalanceMultiplier as [Tax Amount],
		tax.TaxRuleId as [Tax Rule ID],
		taxr.Name as [Tax Name],
		taxr.Description as [Tax Description],
		ISNULL(taxr.RegistrationCode, '') as [Tax Code],
		taxr.TaxCode as [Unique Tax Code],
		cast(taxr.Percentage  as float) as [Tax Percentage],	
		t.TaxesPayableDebit as [Taxes Payable Debit],
		t.TaxesPayableCredit as [Taxes Payable Credit],
		t.CustomerId
	FROM #FilteredTransactionData t
		INNER JOIN ReverseTax rtax on t.Id = rtax.Id
		INNER JOIN Tax tax on rtax.OriginalTaxId = tax.Id
		INNER JOIN TaxRule taxr on tax.TaxRuleId = taxr.Id 
		INNER JOIN Charge ch on tax.ChargeId = ch.Id
		INNER JOIN ReversalAmounts rch on rch.OriginalChargeId = ch.Id
		INNER JOIN #FullTransactionData rcht on rcht.Id = ch.Id
		LEFT OUTER JOIN GLCode gl on gl.Id = ch.GLCodeId
		INNER JOIN Invoice i on i.Id = ch.InvoiceId
		INNER JOIN PurchaseCharge pc on ch.Id = pc.Id
		LEFT OUTER JOIN ReverseDiscountAmounts on ReverseDiscountAmounts.ReverseChargeId = ch.Id
		LEFT OUTER JOIN PaymentSchedule ps on i.Id = ps.InvoiceId
		LEFT OUTER JOIN JournalAtReport jj on ps.Id = jj.PaymentScheduleId
		LEFT OUTER JOIN PaymentScheduleJournal psj1 on psj1.Id = jj.Id
		LEFT OUTER JOIN PaymentScheduleJournal psj2 on ps.Id = psj2.PaymentScheduleId AND psj2.IsActive = 1
		INNER JOIN Lookup.InvoiceStatus InvoiceStatusAtTime on InvoiceStatusAtTime.Id = psj1.StatusId
		INNER JOIN Lookup.InvoiceStatus CurrentInvoiceStatus on CurrentInvoiceStatus.Id = psj2.StatusId
	WHERE t.TransactionTypeId = 12

	UNION ALL
	-- purchase charges
	SELECT
		t.id as [Transaction ID],
		t.TransactionType as [Tax Charge Type (Tax Charge or Tax Reversal)],
		convert(datetime,dbo.fn_GetTimezoneTime(t.EffectiveTimestamp,t.TimezoneId )) as [Tax Effective Date],
		ch.Id [Source Charge Id],
		cht.TransactionType as [Source Charge Transaction Type],
		ch.Name as [Source Charge Name],
		ISNULL(cht.[Description], '') as [Source Charge Description],
		'' as [Source Charge Plan Code],
		'' as [Source Charge Product Code],
		ISNULL(gl.Name, '') as [Source Charge GL Code],
		'' as [Source Charge Subscription ID],
		pc.Id as [Source Charge Purchase ID],
		convert(datetime,dbo.fn_GetTimezoneTime(cht.EffectiveTimestamp,t.TimezoneId )) as [Source Charge Posted Date],
		'' as [Source Charge Service Start],
		'' as [Source Charge Service End],
		i.Id as [Invoice ID],
		i.InvoiceNumber as [Invoice Number],
		InvoiceStatusAtTime.Name as [Invoice Status At Report End Date],
		CurrentInvoiceStatus.Name as [Current Invoice Status],
		convert(datetime,dbo.fn_GetTimezoneTime(psj2.CreatedTimestamp,t.TimezoneId )) as [Last Invoice Status Date],
		t.IsoName as [Currency],
		cht.Amount as [Source Charge Original Amount],
		ISNULL(DiscountAmounts.DiscountTotal, 0) as [Source Charge Original Discount Amount],
		cht.Amount - ISNULL(DiscountAmounts.DiscountTotal, 0) as [Source Charge Net Amount at Report Date], -- source charge - any reversals
		t.Amount* t.ARBalanceMultiplier as [Tax Amount],
		tax.TaxRuleId as [Tax Rule ID],
		taxr.Name as [Tax Name],
		taxr.Description as [Tax Description],
		ISNULL(taxr.RegistrationCode, '') as [Tax Code],
		taxr.TaxCode as [Unique Tax Code],
		cast(taxr.Percentage  as float) as [Tax Percentage],	
		t.TaxesPayableDebit as [Taxes Payable Debit],
		t.TaxesPayableCredit as [Taxes Payable Credit],
		t.CustomerId
	FROM #FilteredTransactionData t
		INNER JOIN Tax tax on t.Id = tax.Id
		INNER JOIN TaxRule taxr on tax.TaxRuleId = taxr.Id 
		INNER JOIN Charge ch on tax.ChargeId = ch.Id
		INNER JOIN #FullTransactionData cht on cht.Id = ch.Id
		LEFT OUTER JOIN GLCode gl on gl.Id = ch.GLCodeId
		INNER JOIN Invoice i on i.Id = ch.InvoiceId
		INNER JOIN PurchaseCharge pc on ch.Id = pc.Id
		LEFT OUTER JOIN DiscountAmounts on DiscountAmounts.ChargeId = ch.Id
		LEFT OUTER JOIN PaymentSchedule ps on i.Id = ps.InvoiceId
		LEFT OUTER JOIN JournalAtReport jj on ps.Id = jj.PaymentScheduleId
		LEFT OUTER JOIN PaymentScheduleJournal psj1 on psj1.Id = jj.Id
		LEFT OUTER JOIN PaymentScheduleJournal psj2 on ps.Id = psj2.PaymentScheduleId AND psj2.IsActive = 1
		INNER JOIN Lookup.InvoiceStatus InvoiceStatusAtTime on InvoiceStatusAtTime.Id = psj1.StatusId
		INNER JOIN Lookup.InvoiceStatus CurrentInvoiceStatus on CurrentInvoiceStatus.Id = psj2.StatusId
	WHERE t.TransactionTypeId = 11

	UNION ALL

	-- subscription products void reversals
	SELECT
		t.id as [Transaction ID],
		t.TransactionType as [Tax Charge Type (Tax Charge or Tax Reversal)],
		convert(datetime,dbo.fn_GetTimezoneTime(t.EffectiveTimestamp,t.TimezoneId )) as [Tax Effective Date],
		ch.Id [Source Charge Id],
		rcht.TransactionType as [Source Charge Transaction Type],
		ch.Name as [Source Charge Name],
		ISNULL(rcht.[Description], '') as [Source Charge Description],
		s.PlanCode as [Source Charge Plan Code],
		pr.Code as [Source Charge Product Code],
		ISNULL(gl.Name, '') as [Source Charge GL Code],
		sp.SubscriptionId as [Source Charge Subscription ID],
		'' as [Source Charge Purchase ID],
		convert(datetime,dbo.fn_GetTimezoneTime(rcht.EffectiveTimestamp,t.TimezoneId )) as [Source Charge Posted Date],
		convert(datetime,dbo.fn_GetTimezoneTime(spc.StartServiceDate,t.TimezoneId )) as [Source Charge Service Start],
		convert(datetime,dbo.fn_GetTimezoneTime(spc.EndServiceDate,t.TimezoneId )) as [Source Charge Service End],
		i.Id as [Invoice ID],
		i.InvoiceNumber as [Invoice Number],
		InvoiceStatusAtTime.Name as [Invoice Status At Report End Date],
		CurrentInvoiceStatus.Name as [Current Invoice Status],
		convert(datetime,dbo.fn_GetTimezoneTime(psj2.CreatedTimestamp,t.TimezoneId )) as [Last Invoice Status Date],
		t.IsoName as [Currency],
		-rch.ReversalTotal as [Source Charge Original Amount],
		ISNULL(ReverseDiscountAmounts.ReverseDiscountTotal, 0) as [Source Charge Original Discount Amount],
		-rch.ReversalTotal + ISNULL(ReverseDiscountAmounts.ReverseDiscountTotal, 0) as [Source Charge Net Amount at Report Date], -- source charge - any reversals
		t.Amount* t.ARBalanceMultiplier as [Tax Amount],
		tax.TaxRuleId as [Tax Rule ID],
		taxr.Name as [Tax Name],
		taxr.Description as [Tax Description],
		ISNULL(taxr.RegistrationCode,'') as [Tax Code],
		taxr.TaxCode as [Unique Tax Code],
		cast(taxr.Percentage  as float) as [Tax Percentage],	
		t.TaxesPayableDebit as [Taxes Payable Debit],
		t.TaxesPayableCredit as [Taxes Payable Credit],
		t.CustomerId
	FROM #FilteredTransactionData t
		INNER JOIN VoidReverseTax vtx ON vtx.Id = t.Id
		INNER JOIN ReverseTax rtax on vtx.OriginalReverseTaxId = rtax.Id
		INNER JOIN Tax tax on rtax.OriginalTaxId = tax.Id
		INNER JOIN TaxRule taxr on tax.TaxRuleId = taxr.Id 
		INNER JOIN Charge ch on tax.ChargeId = ch.Id
		INNER JOIN ReversalAmounts rch on rch.OriginalChargeId = ch.Id
		INNER JOIN #FullTransactionData rcht on rcht.Id = ch.Id
		LEFT OUTER JOIN GLCode gl on gl.Id = ch.GLCodeId
		INNER JOIN Invoice i on i.Id = ch.InvoiceId
		INNER JOIN SubscriptionProductCharge spc on ch.Id = spc.Id
		INNER JOIN SubscriptionProduct sp on spc.SubscriptionProductId = sp.Id
		INNER JOIN Subscription s ON s.Id = sp.SubscriptionId
		INNER JOIN Product pr on sp.ProductId = pr.Id
		LEFT OUTER JOIN ReverseDiscountAmounts on ReverseDiscountAmounts.ReverseChargeId = ch.Id
		LEFT OUTER JOIN PaymentSchedule ps on i.Id = ps.InvoiceId
		LEFT OUTER JOIN JournalAtReport jj on ps.Id = jj.PaymentScheduleId
		LEFT OUTER JOIN PaymentScheduleJournal psj1 on psj1.Id = jj.Id
		LEFT OUTER JOIN PaymentScheduleJournal psj2 on ps.Id = psj2.PaymentScheduleId AND psj2.IsActive = 1	
		INNER JOIN Lookup.InvoiceStatus InvoiceStatusAtTime on InvoiceStatusAtTime.Id = psj1.StatusId
		INNER JOIN Lookup.InvoiceStatus CurrentInvoiceStatus on CurrentInvoiceStatus.Id = psj2.StatusId
	WHERE t.TransactionTypeId = 30

	UNION ALL

	-- subscription products reversals
	SELECT
		t.id as [Transaction ID],
		t.TransactionType as [Tax Charge Type (Tax Charge or Tax Reversal)],
		convert(datetime,dbo.fn_GetTimezoneTime(t.EffectiveTimestamp,t.TimezoneId )) as [Tax Effective Date],
		ch.Id [Source Charge Id],
		rcht.TransactionType as [Source Charge Transaction Type],
		ch.Name as [Source Charge Name],
		ISNULL(rcht.[Description], '') as [Source Charge Description],
		s.PlanCode as [Source Charge Plan Code],
		pr.Code as [Source Charge Product Code],
		ISNULL(gl.Name, '') as [Source Charge GL Code],
		sp.SubscriptionId as [Source Charge Subscription ID],
		'' as [Source Charge Purchase ID],
		convert(datetime,dbo.fn_GetTimezoneTime(rcht.EffectiveTimestamp,t.TimezoneId )) as [Source Charge Posted Date],
		convert(datetime,dbo.fn_GetTimezoneTime(spc.StartServiceDate,t.TimezoneId )) as [Source Charge Service Start],
		convert(datetime,dbo.fn_GetTimezoneTime(spc.EndServiceDate,t.TimezoneId )) as [Source Charge Service End],
		i.Id as [Invoice ID],
		i.InvoiceNumber as [Invoice Number],
		InvoiceStatusAtTime.Name as [Invoice Status At Report End Date],
		CurrentInvoiceStatus.Name as [Current Invoice Status],
		convert(datetime,dbo.fn_GetTimezoneTime(psj2.CreatedTimestamp,t.TimezoneId )) as [Last Invoice Status Date],
		t.IsoName as [Currency],
		-rch.ReversalTotal as [Source Charge Original Amount],
		ISNULL(ReverseDiscountAmounts.ReverseDiscountTotal, 0) as [Source Charge Original Discount Amount],
		-rch.ReversalTotal + ISNULL(ReverseDiscountAmounts.ReverseDiscountTotal, 0) as [Source Charge Net Amount at Report Date], -- source charge - any reversals
		t.Amount* t.ARBalanceMultiplier as [Tax Amount],
		tax.TaxRuleId as [Tax Rule ID],
		taxr.Name as [Tax Name],
		taxr.Description as [Tax Description],
		ISNULL(taxr.RegistrationCode,'') as [Tax Code],
		taxr.TaxCode as [Unique Tax Code],
		cast(taxr.Percentage  as float) as [Tax Percentage],	
		t.TaxesPayableDebit as [Taxes Payable Debit],
		t.TaxesPayableCredit as [Taxes Payable Credit],
		t.CustomerId
	FROM #FilteredTransactionData t
		INNER JOIN ReverseTax rtax on t.Id = rtax.Id
		INNER JOIN Tax tax on rtax.OriginalTaxId = tax.Id
		INNER JOIN TaxRule taxr on tax.TaxRuleId = taxr.Id 
		INNER JOIN Charge ch on tax.ChargeId = ch.Id
		INNER JOIN ReversalAmounts rch on rch.OriginalChargeId = ch.Id
		INNER JOIN #FullTransactionData rcht on rcht.Id = ch.Id
		LEFT OUTER JOIN GLCode gl on gl.Id = ch.GLCodeId
		INNER JOIN Invoice i on i.Id = ch.InvoiceId
		INNER JOIN SubscriptionProductCharge spc on ch.Id = spc.Id
		INNER JOIN SubscriptionProduct sp on spc.SubscriptionProductId = sp.Id
		INNER JOIN Subscription s ON s.Id = sp.SubscriptionId
		INNER JOIN Product pr on sp.ProductId = pr.Id
		LEFT OUTER JOIN ReverseDiscountAmounts on ReverseDiscountAmounts.ReverseChargeId = ch.Id
		LEFT OUTER JOIN PaymentSchedule ps on i.Id = ps.InvoiceId
		LEFT OUTER JOIN JournalAtReport jj on ps.Id = jj.PaymentScheduleId
		LEFT OUTER JOIN PaymentScheduleJournal psj1 on psj1.Id = jj.Id
		LEFT OUTER JOIN PaymentScheduleJournal psj2 on ps.Id = psj2.PaymentScheduleId AND psj2.IsActive = 1	
		INNER JOIN Lookup.InvoiceStatus InvoiceStatusAtTime on InvoiceStatusAtTime.Id = psj1.StatusId
		INNER JOIN Lookup.InvoiceStatus CurrentInvoiceStatus on CurrentInvoiceStatus.Id = psj2.StatusId
	WHERE t.TransactionTypeId = 12

	UNION ALL
	--subscription product charges
	SELECT
		t.id as [Transaction ID],
		t.TransactionType as [Tax Charge Type (Tax Charge or Tax Reversal)],
		convert(datetime,dbo.fn_GetTimezoneTime(t.EffectiveTimestamp,t.TimezoneId )) as [Tax Effective Date],
		ch.Id [Source Charge Id],
		cht.TransactionType as [Source Charge Transaction Type],
		ch.Name as [Source Charge Name],
		ISNULL(cht.[Description], '') as [Source Charge Description],
		s.PlanCode as [Source Charge Plan Code],
		pr.Code as [Source Charge Product Code],
		ISNULL(gl.Name, '') as [Source Charge GL Code],
		sp.SubscriptionId as [Source Charge Subscription ID],
		'' as [Source Charge Purchase ID],
		convert(datetime,dbo.fn_GetTimezoneTime(cht.EffectiveTimestamp,t.TimezoneId )) as [Source Charge Posted Date],
		convert(datetime,dbo.fn_GetTimezoneTime(spc.StartServiceDate,t.TimezoneId )) as [Source Charge Service Start],
		convert(datetime,dbo.fn_GetTimezoneTime(spc.EndServiceDate,t.TimezoneId )) as [Source Charge Service End],
		i.Id as [Invoice ID],
		i.InvoiceNumber as [Invoice Number],
		InvoiceStatusAtTime.Name as [Invoice Status At Report End Date],
		CurrentInvoiceStatus.Name as [Current Invoice Status],
		convert(datetime,dbo.fn_GetTimezoneTime(psj2.CreatedTimestamp,t.TimezoneId )) as [Last Invoice Status Date],
		t.IsoName as [Currency],
		cht.Amount as [Source Charge Original Amount],
		ISNULL(DiscountAmounts.DiscountTotal, 0) as [Source Charge Original Discount Amount],
		cht.Amount - ISNULL(DiscountAmounts.DiscountTotal, 0) as [Source Charge Net Amount at Report Date], -- source charge - any reversals
		t.Amount* t.ARBalanceMultiplier as [Tax Amount],
		tax.TaxRuleId as [Tax Rule ID],
		taxr.Name as [Tax Name],
		taxr.Description as [Tax Description],
		ISNULL(taxr.RegistrationCode,'') as [Tax Code],
		taxr.TaxCode as [Unique Tax Code],
		cast(taxr.Percentage  as float) as [Tax Percentage],	
		t.TaxesPayableDebit as [Taxes Payable Debit],
		t.TaxesPayableCredit as [Taxes Payable Credit],
		--,Customer.*
		t.CustomerId
	FROM #FilteredTransactionData t
		INNER JOIN Tax tax on t.Id = tax.Id
		INNER JOIN TaxRule taxr on tax.TaxRuleId = taxr.Id 
		INNER JOIN Charge ch on tax.ChargeId = ch.Id
		INNER JOIN #FullTransactionData cht on cht.Id = ch.Id
		LEFT OUTER JOIN GLCode gl on gl.Id = ch.GLCodeId
		INNER JOIN Invoice i on i.Id = ch.InvoiceId
		INNER JOIN SubscriptionProductCharge spc on ch.Id = spc.Id
		INNER JOIN SubscriptionProduct sp on spc.SubscriptionProductId = sp.Id
		INNER JOIN Subscription s ON s.Id = sp.SubscriptionId
		INNER JOIN Product pr on sp.ProductId = pr.Id
		LEFT OUTER JOIN DiscountAmounts on DiscountAmounts.ChargeId = ch.Id
		LEFT OUTER JOIN PaymentSchedule ps on i.Id = ps.InvoiceId
		LEFT OUTER JOIN JournalAtReport jj on ps.Id = jj.PaymentScheduleId
		LEFT OUTER JOIN PaymentScheduleJournal psj1 on psj1.Id = jj.Id
		LEFT OUTER JOIN PaymentScheduleJournal psj2 on ps.Id = psj2.PaymentScheduleId AND psj2.IsActive = 1	
		INNER JOIN Lookup.InvoiceStatus InvoiceStatusAtTime on InvoiceStatusAtTime.Id = psj1.StatusId
		INNER JOIN Lookup.InvoiceStatus CurrentInvoiceStatus on CurrentInvoiceStatus.Id = psj2.StatusId
	WHERE t.TransactionTypeId = 11
	) [Data]

;WITH CTE_Results AS (
	SELECT DISTINCT
	[Transaction ID]
	,[Tax Charge Type (Tax Charge or Tax Reversal)]
	,[Tax Effective Date]
	,[Source Charge Id]
	,[Source Charge Transaction Type]
	,[Source Charge Name]
	,[Source Charge Description]
	,[Source Charge Plan Code]
	,[Source Charge Product Code]
	,[Source Charge GL Code]
	,[Source Charge Subscription ID]
	,[Source Charge Purchase ID]
	,[Source Charge Posted Date]
	,[Source Charge Service Start]
	,[Source Charge Service End]
	,[Invoice ID]
	,[Invoice Number]
	,CASE WHEN COUNT(*) > 1 THEN 'See Payment Schedule' ELSE MAX([Invoice Status At Report End Date]) END [Invoice Status At Report End Date]
	,CASE WHEN COUNT(*) > 1 THEN 'See Payment Schedule' ELSE MAX([Current Invoice Status]) END [Current Invoice Status]
	,MAX([Last Invoice Status Date]) as [Last Invoice Status Date]
	,[Currency]
	,[Source Charge Original Amount]
	,[Source Charge Original Discount Amount]
	,[Source Charge Net Amount at Report Date]
	,[Tax Amount]
	,[Tax Rule ID]
	,[Tax Name]
	,[Tax Description]
	,[Tax Code]
	,[Unique Tax Code]
	,[Tax Percentage]
	,[Taxes Payable Debit]
	,[Taxes Payable Credit]
	,CustomerId
	FROM #Results
	GROUP BY 
	[Transaction ID]
	,[Tax Charge Type (Tax Charge or Tax Reversal)]
	,[Tax Effective Date]
	,[Source Charge Id]
	,[Source Charge Transaction Type]
	,[Source Charge Name]
	,[Source Charge Description]
	,[Source Charge Plan Code]
	,[Source Charge Product Code]
	,[Source Charge GL Code]
	,[Source Charge Subscription ID]
	,[Source Charge Purchase ID]
	,[Source Charge Posted Date]
	,[Source Charge Service Start]
	,[Source Charge Service End]
	,[Invoice ID]
	,[Invoice Number]
	,[Currency]
	,[Source Charge Original Amount]
	,[Source Charge Original Discount Amount]
	,[Source Charge Net Amount at Report Date]
	,[Tax Amount]
	,[Tax Rule ID]
	,[Tax Name]
	,[Tax Description]
	,[Tax Code]
	,[Unique Tax Code]
	,[Tax Percentage]
	,[Taxes Payable Debit]
	,[Taxes Payable Credit]
	,CustomerId
)
SELECT DISTINCT
[Transaction ID]
,[Tax Charge Type (Tax Charge or Tax Reversal)]
,[Tax Effective Date]
,[Source Charge Id]
,[Source Charge Transaction Type]
,[Source Charge Name]
,[Source Charge Description]
,[Source Charge Plan Code]
,[Source Charge Product Code]
,[Source Charge GL Code]
,[Source Charge Subscription ID]
,[Source Charge Purchase ID]
,[Source Charge Posted Date]
,[Source Charge Service Start]
,[Source Charge Service End]
,[Invoice ID]
,[Invoice Number]
,[Invoice Status At Report End Date]
,[Current Invoice Status]
,[Last Invoice Status Date]
,[Currency]
,[Source Charge Original Amount]
,[Source Charge Original Discount Amount]
,[Source Charge Net Amount at Report Date]
,[Tax Amount]
,[Tax Rule ID]
,[Tax Name]
,[Tax Description]
,[Tax Code]
,[Unique Tax Code]
,[Tax Percentage]
,[Taxes Payable Debit]
,[Taxes Payable Credit]
,c.*
FROM CTE_Results r
INNER JOIN #CustomerData c ON c.[Fusebill Id] = r.CustomerId

DROP TABLE #FullTransactionData
DROP TABLE #FilteredTransactionData
DROP TABLE #Results
DROP TABLE #CustomerData

GO

