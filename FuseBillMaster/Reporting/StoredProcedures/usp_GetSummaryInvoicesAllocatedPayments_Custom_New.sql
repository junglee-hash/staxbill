



/*
HISTORY
Version | By | Date | Description | For
v1 | Mark Cerullo | APR2023 | New Invoices with Payment Allcations ++ - Main goal to combine full payment info with invoices and filter by products | Stellar - 26457

Notes
* Links summary invoices with payments allocated to invoices only (payments not used to pay off invoices are not included)
* Does not consider payment schedules (uses only default payment schedules of 1)
* Combines all unique product codes (planproducts and purchases) in the detailed invoice into csv column for easy searching on lines items in the invoice
* Refunds are treated as a complimentary transaction to the initial payment as opposed to a completely separate transaction
* Provides full billingperiod info per invoice
* Used built in SQL convert for utc to local conversion
* Uses inclusive start date on posted invoices and "less than" for end date (eg. Jan1 to Feb1 will yield everything in Jan)

v1.1 | Mark Cerullo | JUN2024 | New Invoices with Payment Allcations ++ - Main goal to combine full payment info with invoices and filter by products | Stellar - 26457

Notes
* Customer began using Purchases (invoices) which don't have billing periods. Removed inner join on Billing Period tables to adjust
* Prefixed the query to find invoice Ids with allocations first for performance went from 1:20 to 1sec
*/


/* Reenable for PROD */

CREATE   PROCEDURE [Reporting].[usp_GetSummaryInvoicesAllocatedPayments_Custom_New]

	 @AccountId BIGINT
	,@StartDate DATETIME 
	,@EndDate DATETIME

AS 

BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT
	SET NOCOUNT ON

DECLARE @TimezoneId INT

SELECT 
	 @TimezoneId = [ap].[TimezoneId]
FROM 
	[AccountPreference] ap
WHERE [ap].[Id] = @AccountId

--Target Specific invoices with payment allocations first
CREATE TABLE #AllocatedInvoiceIds
( 
	AllocatedInvoiceId BIGINT 
);

INSERT INTO #AllocatedInvoiceIds
	SELECT ii.id from invoice ii 
	JOIN PaymentNote pnn ON ii.id=pnn.InvoiceId 
	WHERE ii.AccountId = @AccountId 
	AND pnn.EffectiveTimestamp >= @StartDate 
	AND pnn.EffectiveTimestamp < @EndDate


; WITH cte as
(
	SELECT 
		[c].[InvoiceId],
		[sp].[PlanProductCode] AS [ProductCode]
	FROM
	[Charge] c
	INNER JOIN [SubscriptionProductActivityJournalCharge] spacjc ON [c].[id] = [spacjc].[ChargeId]
	INNER JOIN [SubscriptionProductActivityJournal] spaj ON [spaj].[id]=[spacjc].[SubscriptionProductActivityJournalId]
	INNER JOIN SubscriptionProduct sp ON [sp].[Id]=[spaj].[SubscriptionProductId]
	INNER JOIN [Invoice] i ON [i].[id]=[c].[InvoiceId]
	WHERE 
		[i].[AccountId] = @AccountId

	UNION

	SELECT 
		[c].[InvoiceId],
		[prd].[Code] AS [ProductCode]
	FROM
		[Charge] c
		INNER JOIN PurchaseCharge pc ON [pc].[id] = [c].[id]
		INNER JOIN [Purchase] p	ON [p].[id]=[pc].[PurchaseId]
		INNER JOIN [Product] prd ON [prd].[id] = [p].[ProductId]
		INNER JOIN [Invoice] i 	ON [i].[id]=[c].[InvoiceId]
	WHERE 
		[i].[AccountId] = @AccountId
)

SELECT
	   [i].[Id] AS [InvoiceId]
	  ,[i].[CustomerId] AS [StaxBillId]
	  ,[ic].[Reference] AS [CustomerId]	
      ,[i].[InvoiceNumber]
	  ,[ic].[CompanyName]	  
	  ,[ic].[FirstName] + ' ' + [ic].[LastName] AS [CustomerName]
      ,(SELECT TimezoneDateTime from Timezone.tvf_GetTimezoneTime(@TimezoneId,[i].[CreatedTimestamp])) AS [CreatedDate]
	  ,(SELECT TimezoneDateTime from Timezone.tvf_GetTimezoneTime(@TimezoneId,[i].[PostedTimestamp])) AS [PostedDate]
	  ,(SELECT TimezoneDateTime from Timezone.tvf_GetTimezoneTime(@TimezoneId,[i].[EffectiveTimestamp])) AS [EffectiveDate]   
      ,[i].[PoNumber]
      ,[i].[OpeningArBalance]
      ,[i].[ClosingArBalance]
      ,[i].[TotalInstallments] AS [PaymentInstallments]										
	  ,ISNULL([tm].[Name],[tm1].[Name]) AS [InvoiceTerms]
      ,[ij].[SumOfCharges] AS [TotalCharges]
      ,[ij].[SumOfPayments] AS [TotalPayments]
      ,[ij].[SumOfRefunds] AS [TotalRefunds]
      ,[ij].[SumOfCreditNotes] AS [TotalCreditNotes]
      ,[ij].[SumOfWriteOffs] AS [TotalWriteOffs]
      ,[ij].[OutstandingBalance] AS [OutstandingBalance]
	  ,CONVERT(DATE,[psj].[DueDate]) AS [DueDate]
	  ,[psch].[Amount]
	  ,[psch].[DaysDueAfterTerm]
	  ,[psch].[IsDefault]
	  ,[psch].[InstallmentNumber]
	  ,[psch].[ScheduledDueDate]
      ,[ij].[SumOfTaxes] AS [TotalTaxes]
      ,[ij].[SumOfDiscounts] AS [TotalDiscounts]
	  ,[ists].[Name] AS [InvoiceStatus]
	  ,[productlist].[ProductCodeCharges]	
	  ,[bpd].[Id] AS [BillingPeriodDefintionId]
	  ,CONVERT(DATE,[bp].[StartDate]) AS [BillingPeriodStartDate]  
	  ,CONVERT(DATE,[bp].[EndDate]) AS [BillingPeriodEndDate]
	  ,CONVERT(DATE,[bp].[RechargeDate]) AS [BillingPeriodRechargeDate]
	  ,[li].Name AS [BillingPeriodInterval]
      ,[bpd].[NumberOfIntervals] AS [BillingPeriodNumberOfIntervals]
      ,[bpd].[InvoiceDay] AS [BillingPeriodInvoiceDay]
	  ,[lbpt].Name AS [BillingperiodType]
      ,[bpd].[InvoiceMonth] AS [BillingPeriodMonth]
      ,[bpd].[InvoiceInAdvance] AS [BillingPeriodInvoiceInAdvanceDays]		
      ,ISNULL([bpd].[AutoCollect],ISNULL([cbs].[AutoCollect],[paymentInfo].[AccountDefaultAutoCollect])) AS [BillingPeriodAutoCollect]
	  ,ISNULL([bpd].[AutoPost],ISNULL([cbs].[AutoPostDraftInvoice],[paymentInfo].[AccountDefaultAutoPost])) AS [BillingPeriodAutoPost]
      ,ISNULL([lt].[Name],[paymentInfo].[AccountDefaultTerms]) AS [BillingPeriodTerms]
      ,[bpd].[PoNumber] AS [BillingPeriodPONumber]
	  ,[i].[QuickBooksId]
      ,[i].[NetsuiteId]
      ,[i].[ErpNetsuiteId]
	  ,[i].[AvalaraId]
	  ,[i].[SalesforceId]
	  ,[paymentInfo].*

  FROM 
	[Invoice] i
	INNER JOIN [InvoiceCustomer] ic	ON [ic].[InvoiceId]=[i].[Id]
	INNER JOIN CustomerBillingSetting cbs ON [cbs].[Id]=[i].[CustomerId]
	LEFT OUTER JOIN [Lookup].[Term] tm ON [tm].[Id]=[i].[TermId]
	LEFT OUTER JOIN [Lookup].[Term] tm1 ON [tm1].[Id]=[cbs].[TermId]
	INNER JOIN [InvoiceJournal] ij ON [ij].[InvoiceId]=[i].[Id]
	INNER JOIN [PaymentSchedule] psch ON [psch].[InvoiceId]=[i].[Id]		
	INNER JOIN [PaymentScheduleJournal] psj	ON [psj].[PaymentScheduleId]=[psch].[Id]
	INNER JOIN [Lookup].[InvoiceStatus] ists ON [ists].[Id]=[psj].[StatusId]
	LEFT JOIN [BillingPeriod] bp ON [bp].[id]=[i].[BillingPeriodId]
	LEFT JOIN [BillingPeriodDefinition] bpd	ON [bpd].[id]=[bp].[BillingPeriodDefinitionId]
	LEFT JOIN [Lookup].[BillingPeriodType] lbpt ON [lbpt].[Id]=[bpd].[BillingPeriodTypeId]			
	LEFT JOIN [Lookup].[Interval] li ON [li].[Id]=[bpd].[IntervalId]
	LEFT JOIN [Lookup].[Term] lt ON [lt].[Id]=[bpd].[TermId]

	INNER JOIN				--Add a column of all distinct product codes in the invoice that can be used for filtering
		(SELECT DISTINCT 
			[InvoiceId]
			,ProductCodeCharges = STUFF((SELECT ',' + CONVERT(NVARCHAR(MAX), [sp1].[ProductCode]) FROM cte sp1 WHERE [sp1].[InvoiceId]=[sp2].[InvoiceId] FOR XML PATH('')),1,1,'')
		FROM
			cte	sp2) productlist
		ON [productlist].[InvoiceId] = [i].[Id]

	LEFT OUTER JOIN			--Add all payment details
		(SELECT 
			 [paj].[Id] AS [PaymentActivityId]
			,[p].[Id] AS [PaymentId]			
			,(SELECT TimezoneDateTime FROM Timezone.tvf_GetTimezoneTime(@TimezoneId,[paj].[EffectiveTimestamp])) AS [PaymentDate]
			,CASE WHEN [paj].[PaymentTypeId] = 2 THEN [paj].[Amount] 
				ELSE 0 END AS [DebitAmount]
			,CASE WHEN [paj].[PaymentTypeId] = 3 THEN [paj].[Amount] 
				ELSE 0 END AS [CreditAmount]
			,[cr].[IsoName] AS [Currency]
			,[pn].[Amount] AS [AllocatedPaymentAmount]						
			,(SELECT TimezoneDateTime FROM Timezone.tvf_GetTimezoneTime(@TimezoneId,[pn].[EffectiveTimestamp])) AS [AllocatedPaymentDate]
			,[pn1].[Amount] AS [UnAllocatedPaymentAmount]			
			,(SELECT TimezoneDateTime FROM Timezone.tvf_GetTimezoneTime(@TimezoneId,[pn1].[EffectiveTimestamp])) AS [UnAllocatedPaymentDate]
			,(ISNULL([pn].[Amount],0.0) + ISNULL([pn1].[Amount],0.0)) AS [NetAllocation]
			,[pn].[InvoiceId] AS [AllocationInvoiceId]
			,[paj].[CustomerId] AS [StaxBillId]
			,[paj].[ParentCustomerId] AS [ParentStaxBillId]
			,[pt].[Name] AS [PaymentType]																	
			,[p].[Reference] AS [Reference]	
			,[pa].[Name] AS [PaymentStatus]
			,[ps].[Name] AS [PaymentSource]
			,CASE WHEN [pmt].[Id] = 5 THEN 'ACH'
				ELSE [pmt].[Name] END AS [PaymentMethod]
			,[pm].[AccountType] AS [PaymentMethodType]
			,COALESCE ([cc].[MaskedCardNumber], [ac].[MaskedAccountNumber]) AS [LastFour]
			,CASE WHEN [cc].[ExpirationMonth] IS NULL THEN NULL 
				ELSE CONCAT([cc].[ExpirationMonth],'-',[cc].[ExpirationYear]) END AS [CCExpiration]
			,CASE WHEN ([pm].[Id] IS NULL AND [pmt].[Id] = 3) THEN 'True' 
				ELSE 'False' END AS [OneTimePayment]
			,[stc1].[Code] AS [STC1Code]
			,[stc1].[Name] AS [STC1Name]
			,[stc2].[Code] AS [STC2Code]
			,[stc2].[Name] AS [STC2Name]
			,[stc3].[Code] AS [STC3Code]
			,[stc3].[Name] AS [STC3Name]
			,[stc4].[Code] AS [STC4Code]
			,[stc4].[Name] AS [STC4Name]
			,[stc5].[Code] AS [STC5Code]
			,[stc5].[Name] AS [STC5Name]
			,[p].[RefundableAmount] AS [PaymentRefundableAmount]
			,[p].[UnallocatedAmount] AS [PaymentUnallocatedAmount]
			,[paj].[SurchargingFee]
			,[paj].[GatewayFee]
			,[paj].[GatewayId]
			,[paj].[GatewayName]
			,[paj].[ReconciliationId]
			,[paj].[SecondaryTransactionNumber]
			,[paj].[AttemptNumber]
			,[paj].[AuthorizationResponse]
			,CASE WHEN [pm].[Sharing]=1 THEN 'True'
				ELSE 'False' END AS [SharedPaymentMethod]
			,[p].[QuickBooksId] AS [PaymentQuickBooksId]
			,[p].[NetsuiteId] AS [PaymentNetsuiteId]
			,[c].[AccountId] AS [AccountId]
			,[lt].[Name] AS [AccountDefaultTerms]
			,[acp].[DefaultAutoCollect] AS [AccountDefaultAutoCollect]	
			,[acp].[AutoPostDraftInvoice] AS [AccountDefaultAutoPost]	
		FROM
		
			[Payment] p 
			INNER JOIN [PaymentActivityJournal] paj ON [p].[PaymentActivityJournalId] = [paj].[id]
			INNER JOIN [Lookup].[PaymentActivityStatus] pa ON [pa].[Id] = [paj].[PaymentActivityStatusId]
			INNER JOIN [Lookup].[PaymentType] pt ON [pt].[Id] = [paj].[PaymentTypeId]
			INNER JOIN [Lookup].[PaymentSource] ps ON [ps].[Id] = [paj].[PaymentSourceId]
			INNER JOIN [Lookup].[PaymentMethodType] pmt ON [pmt].[Id] = [paj].[PaymentMethodTypeId] 
			INNER JOIN [Lookup].[Currency] cr ON [cr].[Id] = [paj].[CurrencyId]
			LEFT OUTER JOIN [PaymentMethod] pm ON [paj].[PaymentMethodId] = [pm].[Id]
			LEFT OUTER JOIN [CreditCard] cc ON [cc].[Id] = [pm].[Id] 
			LEFT OUTER JOIN [AchCard] ac ON [ac].[Id] = [pm].[Id]
			INNER JOIN [Customer] c ON [c].[Id] = [paj].[CustomerId]
			INNER JOIN [AccountBillingPreference] [acp] ON [acp].[Id]=[c].[AccountId]
			INNER JOIN [Lookup].[Term] lt ON [lt].[Id]=[acp].[DefaultTermId]
			LEFT OUTER JOIN [PaymentNote] pn ON [p].[id]=[pn].[PaymentId] AND pn.Amount > 0
			LEFT OUTER JOIN [PaymentNote] pn1 ON [p].[id]=[pn1].[PaymentId] AND pn1.Amount < 0
			LEFT OUTER JOIN [SalesTrackingCode] stc1 ON [stc1].[id]=[p].[SalesTrackingCode1Id]
			LEFT OUTER JOIN [SalesTrackingCode] stc2 ON [stc2].[id]=[p].[SalesTrackingCode2Id]
			LEFT OUTER JOIN [SalesTrackingCode] stc3 ON [stc3].[id]=[p].[SalesTrackingCode3Id]
			LEFT OUTER JOIN [SalesTrackingCode] stc4 ON [stc4].[id]=[p].[SalesTrackingCode4Id]
			LEFT OUTER JOIN [SalesTrackingCode] stc5 ON [stc5].[id]=[p].[SalesTrackingCode5Id]
		WHERE
			[pt].[Id] IN (2) --Payment
			AND [pn].[Id] IS NOT NULL
	
	) paymentInfo

ON [paymentInfo].[StaxBillId] = [i].[CustomerId] AND [paymentInfo].[AllocationInvoiceId]=[i].[Id]

WHERE 
	[i].[AccountId] = @AccountId 
	AND [paymentInfo].[accountid] =	@AccountId 
	AND	[ij].[IsActive] = 1 
	AND	[psj].[IsActive] = 1 
	AND	[ists].Id = 4	 --Paid only														
	AND [i].[Id] IN (SELECT AllocatedInvoiceId FROM #AllocatedInvoiceIds)

DROP TABLE #AllocatedInvoiceIds
END

GO

