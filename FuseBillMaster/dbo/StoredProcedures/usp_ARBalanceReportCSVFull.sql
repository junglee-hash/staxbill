
CREATE   PROCEDURE [dbo].[usp_ARBalanceReportCSVFull]
@AccountId BIGINT
,@CurrencyId BIGINT
,@StartDate DATETIME
,@EndDate DATETIME

--Testing
--DECLARE 
--@AccountId BIGINT = 20
--,@CurrencyId BIGINT = 2
--,@StartDate DATETIME = '2018-01-01'
--,@EndDate DATETIME = '2018-12-31'

AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT
	SET NOCOUNT ON;
		
	DECLARE @TimezoneId INT

	SELECT @TimezoneId = TimezoneId
	FROM AccountPreference WHERE Id = @AccountId 

	--Temp table to customer details
	SELECT * INTO #CustomerData
	FROM FullCustomerDataByAccount(@AccountId,@CurrencyId,@EndDate)

	----Transactions of Interest
	SELECT t.Id, t.TransactionTypeId, t.AccountId, t.CustomerId, t.[Description], t.EffectiveTimeStamp, t.CurrencyId
	INTO #TransactionsOfInterest
	FROM [Transaction] t
	INNER JOIN [Lookup].TransactionType tt ON tt.Id = t.TransactionTypeId
	WHERE t.AccountId = @AccountId
	AND t.CurrencyId = @CurrencyId
	AND t.EffectiveTimestamp >= @StartDate
	AND t.EffectiveTimestamp < @EndDate
	AND tt.ARBalanceMultiplier <> 0
	
	CREATE INDEX idx1 ON #TransactionsOfInterest(Id)
	CREATE INDEX idx2 ON #TransactionsOfInterest(CustomerId)
	
	--Sum of PaymentNotes by input parameters
	SELECT SUM(pn.Amount) AS Amount
	,PaymentId
	,InvoiceId
	INTO #PaymentNotes
	FROM PaymentNote pn
	INNER JOIN #TransactionsOfInterest t ON t.Id = pn.PaymentId
	WHERE	pn.EffectiveTimestamp >= @StartDate AND 
			pn.EffectiveTimestamp < @EndDate
	GROUP BY 
			pn.InvoiceId, pn.PaymentId


	--Grouped transaction
	SELECT * 
	INTO #GroupedTransactions
	FROM (
		SELECT  
		[Transaction ID]
		,[CustomerId]
		,MAX([Associated Transaction ID]) AS [Associated Transaction ID]
		,[Transaction Type] + ' Unallocated' AS [Transaction Type] 
		,[Name]
		,[Description]
		,[Source Plan Code]
		,[Source Product Code]
		,[Source GL Code]
		,[Source Purchase ID]
		,[Source Subscription ID]
		,[Posted Date]
		,[Service Start]
		,[Service End]
		,'' AS [Invoice ID]
		,'' AS [Invoice Number]
		,[Currency]
		,CASE 
			WHEN [Transaction Type] IN ('Full refund' ,'Partial refund', 'Reverse Credit')
			THEN MAX([Accounts Receivable Debit]) - SUM([Accounts Receivable Debit Note]) 
			ELSE 0 END AS [Accounts Receivable Debit]   
		,CASE 
			WHEN [Transaction Type] = 'Credit' 
			THEN MAX([Accounts Receivable Credit]) - SUM([Accounts Receivable Credit Note]) 
			WHEN [Transaction Type] = 'Payment'
			THEN MAX([Accounts Receivable Credit]) - SUM([Accounts Receivable Credit Note]) 
			ELSE 0 END AS [Accounts Receivable Credit] 
		FROM ( 
		-- INNER SUBQUERY 1
			SELECT  
			t.Id AS [Transaction ID]
			,t.CustomerId
			,ISNULL(CAST(NULLIF(COALESCE(rc.OriginalChargeId,tax.ChargeId,rTax.OriginalTaxId,d.ChargeId,rd.OriginalDiscountId,ref.OriginalPaymentId,''), 0) AS VARCHAR(10)),'') AS [Associated Transaction ID]
			,ltt.[Name] AS [Transaction Type]
			,ISNULL(CASE 
					WHEN t.TransactionTypeId IN (3,4,5) 
					THEN COALESCE(pmt.[Name] + ' (' + pm.AccountType + + ISNULL(' ending in ' + ISNULL(cc.MaskedCardNumber, acc.MaskedAccountNumber),'') + ')', pmt.[Name]) 
					ELSE COALESCE(taxr.[Name], ch.[Name]) 
					END
				,ltt.[Name]) AS [Name]
			,COALESCE(t.[Description], ref.Reference, pay.reference, cred.Reference, ob.Reference, wo.Reference, taxr.[Description], rc.Reference, '') AS [Description]
			,COALESCE(sub.PlanCode,'') AS [Source Plan Code]
			,COALESCE(sp.PlanProductCode,'') AS [Source Product Code]
			,COALESCE(gl.Code,'') AS [Source GL Code]
			,ISNULL(CAST (p.id AS VARCHAR(10)),'') AS [Source Purchase ID]
			,ISNULL(CAST (sub.Id AS VARCHAR(10)),'') AS [Source Subscription ID]
			,CASE 
				WHEN t.EffectiveTimeStamp > '99990101' 
					THEN CONVERT(SMALLDATETIME, CONVERT(DATETIME,t.EffectiveTimeStamp))
				ELSE CONVERT(SMALLDATETIME, DATEADD(MINUTE,interval1.OffsetMinutes,t.EffectiveTimeStamp))
			END AS [Posted Date]
			,CASE
				WHEN ch.EarningEndDate IS NULL OR DATEPART(YEAR, ch.EarningEndDate) >= 2079 -- 2079 is max value for smalldatetime
				THEN '' 
				ELSE --CONVERT(VARCHAR(20), CONVERT(SMALLDATETIME,dbo.fn_GetTimezoneTime(ch.EarningStartDate,@TimezoneId)), 120)
					CONVERT(VARCHAR(20), CONVERT(SMALLDATETIME, DATEADD(MINUTE,interval2.OffsetMinutes,ch.EarningStartDate)), 120)
				END	AS [Service Start]
			,CASE
				WHEN ch.EarningEndDate IS NULL OR DATEPART(YEAR, ch.EarningEndDate) >= 2079 -- 2079 is max value for smalldatetime
				THEN '' 
				ELSE --CONVERT(VARCHAR(20), CONVERT(SMALLDATETIME,dbo.fn_GetTimezoneTime(ch.EarningEndDate,@TimezoneId)), 120)
				CONVERT(VARCHAR(20), CONVERT(SMALLDATETIME, DATEADD(MINUTE,interval3.OffsetMinutes,ch.EarningEndDate)), 120)
				END	AS [Service End]
			,ISNULL(CAST (i.Id AS VARCHAR(10)),'') AS [Invoice ID]
			,ISNULL(CAST (i.InvoiceNumber AS VARCHAR(10)),'') AS [Invoice Number]
			,lc.[IsoName] AS [Currency]
			,CASE 
				WHEN refn.RefundId IS NOT NULL 
				THEN refn.Amount
				WHEN da.DebitId IS NOT NULL
				THEN da.Amount
				ELSE clj.ArDebit 
				END AS [Accounts Receivable Debit Note]
			,clj.ArDebit AS [Accounts Receivable Debit]
			--,pn.PaymentId AS PaymentId
			,CASE WHEN pn.PaymentId IS NOT NULL THEN pn.Amount WHEN cred.Id IS NOT NULL THEN ca.Amount else clj.ArCredit END AS[Accounts Receivable Credit Note]
			,clj.ArCredit AS [Accounts Receivable Credit] -- Take this from PAYMENTNOTE if type is payment
			FROM #TransactionsOfInterest t
			LEFT OUTER JOIN	[Timezone].[ZoneTranslation] ZoneTranslation1 ON ZoneTranslation1.TimezoneId = @TimezoneId 
			LEFT OUTER JOIN [Timezone].[Interval] interval1 ON	COALESCE(ZoneTranslation1.[ParentIANAZoneId],ZoneTranslation1.[IANAZoneId]) = interval1.IANAZoneId AND interval1.UtcStart <= t.EffectiveTimeStamp AND interval1.UtcEnd > t.EffectiveTimeStamp
			INNER JOIN Customer c ON t.CustomerId = c.Id 
			INNER JOIN vw_CustomerLedgerJournal clj ON t.Id = clj.TransactionId 
			INNER JOIN Lookup.TransactionType ltt ON t.TransactionTypeId = ltt.Id
			INNER JOIN Lookup.Currency lc ON t.CurrencyId = lc.Id
			LEFT OUTER JOIN Debit db ON t.Id = db.Id
			LEFT OUTER JOIN	(
				SELECT DebitId,InvoiceId,SUM(Amount) AS Amount
				FROM DebitAllocation
				GROUP BY DebitId,InvoiceId
				) da ON db.Id = da.DebitId AND da.Amount > 0
			LEFT OUTER JOIN Credit cred ON COALESCE(db.OriginalCreditId, t.Id) = cred.Id
			LEFT OUTER JOIN	(
				SELECT CreditId,InvoiceId,SUM(Amount) AS Amount
				FROM CreditAllocation
				GROUP BY CreditId,InvoiceId
				) ca ON cred.Id = ca.CreditId AND ca.Amount > 0 --AND t.Id = cred.Id
			LEFT OUTER JOIN Refund ref ON t.Id = ref.Id
			LEFT OUTER JOIN RefundNote refn ON t.Id = refn.RefundId
			LEFT OUTER JOIN Payment pay ON t.Id = pay.Id
			LEFT OUTER JOIN #PaymentNotes pn ON t.Id = pn.PaymentId
			LEFT OUTER JOIN PaymentActivityJournal paj ON COALESCE(pay.PaymentActivityJournalId, ref.PaymentActivityJournalId) = paj.Id
			LEFT OUTER JOIN Lookup.PaymentMethodType pmt ON paj.PaymentMethodTypeId = pmt.Id
			LEFT OUTER JOIN PaymentMethod pm ON paj.PaymentMethodId = pm.Id
			LEFT OUTER JOIN CreditCard cc ON pm.Id = cc.Id
			LEFT OUTER JOIN AchCard acc ON pm.Id = acc.Id
			LEFT OUTER JOIN VoidReverseCharge vrc ON t.Id = vrc.Id
			LEFT OUTER JOIN VoidReverseDiscount vrd ON t.Id = vrd.Id
			LEFT OUTER JOIN VoidReverseTax vrt ON t.Id = vrt.Id
			LEFT OUTER JOIN	ReverseDiscount rd ON COALESCE(vrd.OriginalReverseDiscountId,t.Id)  = rd.Id
			LEFT OUTER JOIN	Discount d ON COALESCE(rd.OriginalDiscountId, t.Id ) = d.Id
			LEFT OUTER JOIN	ReverseTax rtax ON COALESCE(vrt.OriginalReverseTaxId,t.Id) = rtax.Id
			LEFT OUTER JOIN	Tax tax ON COALESCE(rtax.OriginalTaxId, t.Id ) = tax.Id
			LEFT OUTER JOIN	TaxRule taxr ON tax.TaxRuleId = taxr.Id
			LEFT OUTER JOIN	ReverseCharge rc ON COALESCE(vrc.OriginalReverseChargeId,t.Id)  = rc.Id
			LEFT OUTER JOIN Charge ch ON COALESCE(tax.ChargeId, d.ChargeId, rc.OriginalChargeId, t.Id) = ch.Id
			LEFT OUTER JOIN [Timezone].[Interval] interval2 ON	COALESCE(ZoneTranslation1.[ParentIANAZoneId],ZoneTranslation1.[IANAZoneId]) = interval2.IANAZoneId AND interval2.UtcStart <= ch.EarningStartDate AND interval2.UtcEnd > ch.EarningStartDate
			LEFT OUTER JOIN [Timezone].[Interval] interval3 ON	COALESCE(ZoneTranslation1.[ParentIANAZoneId],ZoneTranslation1.[IANAZoneId]) = interval3.IANAZoneId AND interval3.UtcStart <= ch.EarningEndDate AND interval3.UtcEnd > ch.EarningEndDate
			LEFT OUTER JOIN SubscriptionProductCharge spc ON spc.Id = ch.Id
			LEFT OUTER JOIN SubscriptionProduct sp ON spc.SubscriptionProductId = sp.Id
			LEFT OUTER JOIN Subscription sub ON sp.SubscriptionId = sub.Id
			LEFT OUTER JOIN PurchaseCharge pc ON pc.Id = ch.Id
			LEFT OUTER JOIN Purchase p ON p.Id = pc.PurchaseId
			LEFT OUTER JOIN Product prod ON prod.Id = COALESCE(p.ProductId, sp.ProductId)
			LEFT OUTER JOIN GLCode gl ON gl.Id = COALESCE(ch.GLCodeId, prod.GLCodeId)
			LEFT OUTER JOIN WriteOff wo ON t.Id = wo.Id
			LEFT OUTER JOIN OpeningBalance ob ON t.Id = ob.Id
			LEFT OUTER JOIN OpeningBalanceAllocation oba ON ob.Id = oba.OpeningBalanceId
			LEFT OUTER JOIN Invoice i ON COALESCE(ch.InvoiceId, pn.InvoiceId, ca.InvoiceId, da.InvoiceId, oba.InvoiceId, refn.InvoiceId, wo.InvoiceId) = i.Id
			WHERE (pay.id IS NOT NULL 
					OR cred.Id IS NOT NULL
					OR refn.RefundId IS NOT NULL)
			AND ZoneTranslation1.[Default] = 1						
			) [Inner]
		WHERE [Accounts Receivable Credit note] >= 0 -- ignore any payment refunds which show up as a negative value in the paymentnote table
		GROUP BY 
		[Transaction Id]
		--,[PaymentId]
		,[CustomerId]
		,[Transaction Type]
		,[Name]
		,[Description]
		,[Source Plan Code]
		,[Source Product Code]
		,[Source GL Code]
		,[Source Purchase ID]
		,[Source Subscription ID]
		,[Currency]
		,[Posted Date]
		,[Service Start]
		,[Service End]
	) [Outer]
	WHERE [Accounts Receivable Credit] > 0 or [Accounts Receivable Debit] > 0
	

	--Main section unioned to grouped transaction
	SELECT * 
	INTO #Results
	FROM (
		SELECT  
		t.Id AS [Transaction ID] 
		,t.CustomerId
		,ISNULL(CAST(NULLIF(COALESCE(rTax.OriginalTaxId,rc.OriginalChargeId,tax.ChargeId,rd.OriginalDiscountId,d.ChargeId,ref.OriginalPaymentId,''), 0) AS VARCHAR(10)),'') AS [Associated Transaction ID]
		,ltt.[Name] AS [Transaction Type]
		,ISNULL(CASE 
			WHEN t.TransactionTypeId IN (3,4,5) 
			THEN COALESCE(pmt.[Name] + ' (' + pm.AccountType + + ISNULL(' ending in ' + ISNULL(cc.MaskedCardNumber, acc.MaskedAccountNumber),'') + ')', pmt.[Name]) 
			ELSE COALESCE(taxr.[Name], ch.[Name]) END
			,ltt.[Name]) AS [Name]
		,COALESCE(t.[Description],ref.Reference,pay.reference,cred.Reference,ob.Reference,wo.Reference,taxr.[Description],rc.Reference,'') AS [Description]
		,COALESCE(sub.PlanCode,'') AS [Source Plan Code]
		,COALESCE(sp.PlanProductCode,'') AS [Source Product Code]
		,COALESCE(gl.Code,'') AS [Source GL Code]
		,ISNULL(CAST(p.id AS VARCHAR (10)),'') AS [Source Purchase ID]
		,ISNULL(CAST(sub.Id AS VARCHAR (10)),'') AS [Source Subscription ID]
		,CASE 
			WHEN t.EffectiveTimeStamp > '99990101' 
				THEN CONVERT(SMALLDATETIME, CONVERT(DATETIME,t.EffectiveTimeStamp))
			ELSE CONVERT(SMALLDATETIME, DATEADD(MINUTE,interval1.OffsetMinutes,t.EffectiveTimeStamp))
		END AS [Posted Date]
		,CASE
			WHEN ch.EarningEndDate IS NULL OR t.TransactionTypeId IN (20,7,24,8,18,22,4,5,12,15,11,28,29,30,31,32)  OR DATEPART(YEAR, ch.EarningEndDate) >= 2079 -- 2079 is max value for smalldatetime
			THEN '' 
			ELSE CONVERT(VARCHAR(20), CONVERT(SMALLDATETIME, DATEADD(MINUTE,interval2.OffsetMinutes,ch.EarningStartDate)), 120)
			END	AS [Service Start]
		,CASE
			WHEN ch.EarningEndDate IS NULL OR t.TransactionTypeId IN (20,7,24,8,18,22,4,5,12,15,11,28,29,30,31,32) OR DATEPART(YEAR, ch.EarningEndDate) >= 2079 -- 2079 is max value for smalldatetime
			THEN '' 
			ELSE CONVERT(VARCHAR(20), CONVERT(SMALLDATETIME, DATEADD(MINUTE,interval3.OffsetMinutes,ch.EarningEndDate)), 120)
			END	AS [Service End]
		,ISNULL(CAST(i.Id AS VARCHAR(10)),'') AS [Invoice ID]
		,ISNULL(CAST (i.InvoiceNumber AS VARCHAR(10)),'') AS [Invoice Number]
		,lc.[IsoName] AS [Currency]
		,CASE 
			WHEN refn.RefundId IS NOT NULL 
			THEN refn.Amount
			WHEN da.DebitId IS NOT NULL
			THEN da.Amount
			ELSE clj.ArDebit END AS [Accounts Receivable Debit]
		,CASE 
			WHEN pn.PaymentId IS NOT NULL 
			THEN pn.Amount ELSE 
				CASE 
				WHEN ca.CreditId IS NOT NULL AND db.Id IS NULL
				THEN ca.Amount 
				ELSE clj.ArCredit END END AS [Accounts Receivable Credit]
		FROM #TransactionsOfInterest t 
		LEFT OUTER JOIN	[Timezone].[ZoneTranslation] ZoneTranslation1 ON ZoneTranslation1.TimezoneId = @TimezoneId 
		LEFT OUTER JOIN [Timezone].[Interval] interval1 ON	COALESCE(ZoneTranslation1.[ParentIANAZoneId],ZoneTranslation1.[IANAZoneId]) = interval1.IANAZoneId AND interval1.UtcStart <= t.EffectiveTimeStamp AND interval1.UtcEnd > t.EffectiveTimeStamp
		INNER JOIN Customer c ON t.CustomerId = c.Id 
		INNER JOIN vw_CustomerLedgerJournal AS clj ON t.Id  = clj.TransactionId 
		INNER JOIN Lookup.TransactionType AS ltt ON t.TransactionTypeId = ltt.Id
		INNER JOIN Lookup.Currency lc ON t.CurrencyId = lc.Id
		LEFT OUTER JOIN	Debit AS db ON t.Id  = db.Id
		LEFT OUTER JOIN	(
			SELECT DebitId,InvoiceId,SUM(Amount) AS Amount
			FROM DebitAllocation
			GROUP BY DebitId,InvoiceId
			) da ON db.Id = da.DebitId AND da.Amount > 0
		LEFT OUTER JOIN	Credit AS cred ON COALESCE(db.OriginalCreditId, t.Id ) = cred.Id
		LEFT OUTER JOIN	(
			SELECT CreditId,InvoiceId,SUM(Amount) AS Amount
			FROM CreditAllocation
			GROUP BY CreditId,InvoiceId
			) ca ON cred.Id = ca.CreditId AND ca.Amount > 0 --AND t.Id = cred.Id
		LEFT OUTER JOIN	Refund ref ON t.Id  = ref.Id
		LEFT OUTER JOIN	RefundNote refn ON t.Id  = refn.RefundId
		LEFT OUTER JOIN	Payment pay ON t.Id  = pay.Id
		LEFT OUTER JOIN	#paymentNotes pn ON t.Id  = pn.PaymentId
		LEFT OUTER JOIN	PaymentActivityJournal paj ON COALESCE(pay.PaymentActivityJournalId, ref.PaymentActivityJournalId) = paj.Id
		LEFT OUTER JOIN	Lookup.PaymentMethodType pmt ON paj.PaymentMethodTypeId = pmt.Id
		LEFT OUTER JOIN	PaymentMethod pm ON paj.PaymentMethodId = pm.Id
		LEFT OUTER JOIN	CreditCard cc ON pm.Id = cc.Id
		LEFT OUTER JOIN	AchCard acc ON pm.Id = acc.Id
		LEFT OUTER JOIN VoidReverseCharge vrc ON t.Id = vrc.Id
		LEFT OUTER JOIN VoidReverseDiscount vrd ON t.Id = vrd.Id
		LEFT OUTER JOIN VoidReverseTax vrt ON t.Id = vrt.Id
		LEFT OUTER JOIN	ReverseDiscount rd ON COALESCE(vrd.OriginalReverseDiscountId,t.Id)  = rd.Id
		LEFT OUTER JOIN	Discount d ON COALESCE(rd.OriginalDiscountId, t.Id ) = d.Id
		LEFT OUTER JOIN	ReverseTax rtax ON COALESCE(vrt.OriginalReverseTaxId,t.Id) = rtax.Id
		LEFT OUTER JOIN	Tax tax ON COALESCE(rtax.OriginalTaxId, t.Id ) = tax.Id
		LEFT OUTER JOIN	TaxRule taxr ON tax.TaxRuleId = taxr.Id
		LEFT OUTER JOIN	ReverseCharge rc ON COALESCE(vrc.OriginalReverseChargeId,t.Id)  = rc.Id
		LEFT OUTER JOIN	Charge ch ON COALESCE(tax.ChargeId, d.ChargeId, rc.OriginalChargeId, t.Id ) = ch.Id
		LEFT OUTER JOIN [Timezone].[Interval] interval2 ON	COALESCE(ZoneTranslation1.[ParentIANAZoneId],ZoneTranslation1.[IANAZoneId]) = interval2.IANAZoneId AND interval2.UtcStart <= ch.EarningStartDate AND interval2.UtcEnd > ch.EarningStartDate
		LEFT OUTER JOIN [Timezone].[Interval] interval3 ON	COALESCE(ZoneTranslation1.[ParentIANAZoneId],ZoneTranslation1.[IANAZoneId]) = interval3.IANAZoneId AND interval3.UtcStart <= ch.EarningEndDate AND interval3.UtcEnd > ch.EarningEndDate
		LEFT OUTER JOIN	SubscriptionProductCharge spc ON spc.Id = ch.Id
		LEFT OUTER JOIN	SubscriptionProduct sp ON spc.SubscriptionProductId = sp.Id
		LEFT OUTER JOIN	Subscription sub ON sp.SubscriptionId = sub.Id
		LEFT OUTER JOIN	PurchaseCharge pc ON pc.Id = ch.Id
		LEFT OUTER JOIN	Purchase p ON p.Id = pc.PurchaseId
		LEFT OUTER JOIN	Product prod ON prod.Id = COALESCE(p.ProductId, sp.ProductId)
		LEFT OUTER JOIN GLCode gl ON gl.Id = COALESCE(ch.GLCodeId, prod.GLCodeId)
		LEFT OUTER JOIN	WriteOff wo ON t.Id  = wo.Id
		LEFT OUTER JOIN	OpeningBalance ob ON t.Id  = ob.Id
		LEFT OUTER JOIN	OpeningBalanceAllocation oba ON ob.Id = oba.OpeningBalanceId
		LEFT OUTER JOIN	Invoice i ON COALESCE(ch.InvoiceId, pn.InvoiceId, ca.InvoiceId, da.InvoiceId, oba.InvoiceId, refn.InvoiceId, wo.InvoiceId) = i.Id
		WHERE ((pn.PaymentId IS NOT NULL 
				AND pn.Amount <> 0) 
			OR pn.PaymentId IS NULL) 
		AND ZoneTranslation1.[Default] = 1
		) [Inner]
	WHERE [Accounts Receivable Credit] >= 0 -- ignore any payment refunds which show up as a negative value in the paymentnote table
	UNION 
	SELECT * 
	FROM #GroupedTransactions

	--Index on temp table to improve performance
	CREATE CLUSTERED INDEX [IX_Temp_Results_CustomerId]
	ON #Results ([CustomerId])

	--Final result set with join to Customer details
	SELECT 
	[Transaction ID]
	,[Associated Transaction ID]
	,[Transaction Type] 
	,[Name]
	,[Description]
	,[Source Plan Code]
	,[Source Product Code]
	,[Source GL Code]
	,[Source Purchase ID]
	,[Source Subscription ID]
	,[Posted Date]
	,[Service Start]
	,[Service End]
	,[Invoice ID]
	,[Invoice Number]
	,[Currency]
	,[Accounts Receivable Debit]   
	,[Accounts Receivable Credit]  
	,c.*
	FROM #Results r
	INNER JOIN #CustomerData c ON c.[Fusebill Id] = r.[CustomerId]
	WHERE [Accounts Receivable Debit]  > 0 OR [Accounts Receivable Credit] > 0
	ORDER BY [Transaction ID], [Transaction Type]
	OPTION (RECOMPILE)

-----------------------
DROP TABLE #PaymentNotes
DROP TABLE #CustomerData
DROP TABLE #GroupedTransactions
DROP TABLE #Results
DROP TABLE #TransactionsOfInterest
---------------------

END

GO

