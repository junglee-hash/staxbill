CREATE   PROCEDURE [dbo].[usp_getInvoicesAgingDetailsByDateFull]  
  --required
@AccountId BIGINT = 19
,@ReportDate DATETIME ='2023-07-07'  
,@CurrencyId BIGINT = 1
,@SalesTrackingCodeType INT = NULL      
,@SalesTrackingCodeId BIGINT = NULL      
 
 --Filtering options
,@CustomerId BIGINT = 109
,@CustomerIdSet bit = 0
,@CompanyName NVARCHAR(255) = 'co'
,@CompanyNameSet bit = 0
,@Email NVARCHAR(255) = 'co'
,@EmailSet bit = 0
,@Reference NVARCHAR(255) = '1'
,@ReferenceSet bit = 0

,@Status tinyint = 1
,@StatusSet bit = 0
,@AccountingStatus tinyint = 1
,@AccountingStatusSet bit = 0
,@ParentId BIGINT = 10
,@ParentIdSet bit = 0
,@AgingBucket NVARCHAR(50) = 'DueWithinTerms'
,@AgingBucketSet bit = 0
,@CustomerBalanceGt MONEY = 0
,@CustomerBalanceGtSet bit = 0
,@CustomerBalanceLt MONEY = 0
,@CustomerBalanceLtSet bit = 0
AS  
 
SET TRANSACTION ISOLATION LEVEL SNAPSHOT  
SET NOCOUNT ON;  
 
--Get the customer details and potentially filter by statuses
--Need to join to customer as FullCustomerDataByAccount returns statuses as of the report date

declare @CustomerData dbo.IdList

INSERT INTO @CustomerData (ID)
SELECT c.Id
FROM  Customer c
WHERE c.AccountId = @AccountId
AND c.CurrencyId = @CurrencyId
AND (@CustomerIdSet = 0 OR c.Id = @CustomerId)
   AND (@ParentIdSet = 0 OR c.ParentId = @ParentId)
   AND (@CompanyNameSet = 0 OR c.CompanyName LIKE '%' + @CompanyName + '%')
   AND (@EmailSet = 0 OR c.PrimaryEmail LIKE '%' + @Email + '%')
   AND (@ReferenceSet = 0 OR c.Reference LIKE '%' + @Reference + '%')
   AND (@StatusSet = 0 OR c.StatusId = @Status)
   AND (@AccountingStatusSet = 0 OR c.AccountStatusId = @AccountingStatus)

IF @SalesTrackingCodeType = 1
BEGIN
	if @SalesTrackingCodeId is null
	begin 
		DELETE cd
		FROM @CustomerData cd
		INNER JOIN CustomerReference cr on cr.Id = cd.Id
		WHERE cr.SalesTrackingCode1Id is not null
	end 
	else 
	begin 
		DELETE cd
		FROM @CustomerData cd
		INNER JOIN CustomerReference cr on cr.Id = cd.Id
		WHERE COALESCE(cr.SalesTrackingCode1Id,0) <> COALESCE(@SalesTrackingCodeId,1)
	end
	
END	
IF @SalesTrackingCodeType = 2
BEGIN
	if @SalesTrackingCodeId is null
	begin 
		DELETE cd
		FROM @CustomerData cd
		INNER JOIN CustomerReference cr on cr.Id = cd.Id
		WHERE cr.SalesTrackingCode2Id is not null
	end 
	else 
	begin 
		DELETE cd
		FROM @CustomerData cd
		INNER JOIN CustomerReference cr on cr.Id = cd.Id
		WHERE COALESCE(cr.SalesTrackingCode2Id,0) <> COALESCE(@SalesTrackingCodeId,1)
	end
END	
IF @SalesTrackingCodeType = 3
BEGIN
	if @SalesTrackingCodeId is null
		begin 
			DELETE cd
			FROM @CustomerData cd
			INNER JOIN CustomerReference cr on cr.Id = cd.Id
			WHERE cr.SalesTrackingCode3Id is not null
	end 
	else 
	begin 
		DELETE cd
		FROM @CustomerData cd
		INNER JOIN CustomerReference cr on cr.Id = cd.Id
		WHERE COALESCE(cr.SalesTrackingCode3Id,0) <> COALESCE(@SalesTrackingCodeId,1)
	end
END	
IF @SalesTrackingCodeType = 4
BEGIN
	if @SalesTrackingCodeId is null
	begin 
		DELETE cd
		FROM @CustomerData cd
		INNER JOIN CustomerReference cr on cr.Id = cd.Id
		WHERE cr.SalesTrackingCode4Id is not null
	end 
	else 
	begin 
		DELETE cd
		FROM @CustomerData cd
		INNER JOIN CustomerReference cr on cr.Id = cd.Id
		WHERE COALESCE(cr.SalesTrackingCode4Id,0) <> COALESCE(@SalesTrackingCodeId,1)
	end
END	
IF @SalesTrackingCodeType = 5
BEGIN
	if @SalesTrackingCodeId is null
	begin 
		DELETE cd
		FROM @CustomerData cd
		INNER JOIN CustomerReference cr on cr.Id = cd.Id
		WHERE cr.SalesTrackingCode5Id is not null
	end 
	else 
	begin 
		DELETE cd
		FROM @CustomerData cd
		INNER JOIN CustomerReference cr on cr.Id = cd.Id
		WHERE COALESCE(cr.SalesTrackingCode5Id,0) <> COALESCE(@SalesTrackingCodeId,1)
	end
END		
	

CREATE TABLE #CurrentPaymentScheduleJournal  
(  
PaymentScheduleId bigint primary key not null  
,OutstandingBalance decimal(18,2) not null  
,DaysOld decimal(20,2) not null  
,StatusId int not null  
,DueDate DATETIME NOT NULL  
,InvoiceId BIGINT NOT NULL  
,PaymentScheduleCount INT NOT NULL  
,InvoiceNumber INT NOT NULL
,TermId INT NULL
,PostedTimestamp DATETIME NOT NULL
,CustomerId BIGINT NOT NULL
,BillingPeriodId BIGINT NULL
)    


declare @sqltext nvarchar(2000)
SELECT @sqltext =
CASE WHEN (DATEADD(HOUR,1,@ReportDate) < GETUTCDATE())
THEN N'
Select *
from [dbo].[GetPaymentScheduleJournalsForAgingReports](

@CustomerData,
@AccountId,
@ReportDate

)'
ELSE N'
Select *
from [dbo].[GetActivePaymentScheduleJournalsForAgingReports](

@CustomerData,
@AccountId,
@ReportDate

)'
END
INSERT INTO #CurrentPaymentScheduleJournal execute sp_executesql @sqltext, N'@CustomerData dbo.IdList READONLY,@AccountId BIGINT, @ReportDate DATETIME', @CustomerData = @CustomerData, @AccountId = @AccountId, @ReportDate = @ReportDate
 
 --Figure out which invoices have multiple payment schedules for later invoice number output
;WITH PaymentSchedulesPerInvoice AS (  
 SELECT  
  InvoiceId  
  ,COUNT(*) AS PaymentScheduleCount  
 FROM #CurrentPaymentScheduleJournal  
 GROUP BY InvoiceId  
 HAVING COUNT(*) > 1  
)  
UPDATE cpsj  
SET cpsj.PaymentScheduleCount = pspi.PaymentScheduleCount  
FROM #CurrentPaymentScheduleJournal cpsj  
INNER JOIN PaymentSchedulesPerInvoice pspi ON pspi.InvoiceId = cpsj.InvoiceId  
 
SELECT  
 InvoicesAndPayments.TransactionType AS [Transaction Type]  
 ,InvoicesAndPayments.InvoiceId AS [Invoice ID]  
 ,InvoicesAndPayments.InvoiceNumber AS [Invoice Number]  
 ,InvoicesAndPayments.PostedTimestamp AS [Posted Timestamp]  
 ,InvoicesAndPayments.DueDate AS [Due Date]  
 ,InvoicesAndPayments.PaymentScheduleId AS [Payment Schedule ID]  
 ,InvoicesAndPayments.PaymentId AS [Payment ID]  
 ,InvoicesAndPayments.TotalAmountDue AS [Total Amount Due]  
 ,InvoicesAndPayments.TotalAmountUnallocated AS [Total Amount Unallocated]  
 ,InvoicesAndPayments.Term AS [Term]  
 ,InvoicesAndPayments.DueWithinTerms AS [Due Within Terms]  
 ,InvoicesAndPayments.ZeroToThirtyDaysPastDue AS [Zero To Thirty Days Past Due]  
 ,InvoicesAndPayments.ThirtyOneToSixtyDaysPastDue AS [Thirty-one To Sixty Days Past Due]  
 ,InvoicesAndPayments.SixtyOneToNinetyDaysPastDue AS [Sixty-one To Ninety Days Past Due]  
 ,InvoicesAndPayments.NinetyOneToOneHundredTwentyDaysPastDue AS [Ninety-one To One Hundred Twenty Days Past Due]  
 ,InvoicesAndPayments.MoreThanOneHundredTwentyDaysPastDue AS [More Than One Hundred Twenty Days Past Due]
 ,InvoicesAndPayments.FusebillId AS CustomerId
INTO #ResultSet FROM (  
 SELECT  
  FusebillId  
  ,'Invoice' AS TransactionType  
  ,InvoiceId  
  ,CONVERT(VARCHAR,InvoiceNumber) + CASE WHEN PaymentScheduleCount > 1 THEN '-' + CONVERT(VARCHAR,RowNumber) ELSE + '' END AS InvoiceNumber  
  ,PostedTimestamp  
  ,DueDate  
  ,PaymentScheduleId  
  ,NULL as PaymentId  
  ,TotalAmountDue  
  ,TotalAmountUnallocated  
  ,Term.Name AS Term  
  ,DueWithinTerms  
  ,ZeroToThirtyDaysPastDue  
  ,ThirtyOneToSixtyDaysPastDue  
  ,SixtyOneToNinetyDaysPastDue  
  ,NinetyOneToOneHundredTwentyDaysPastDue  
  ,MoreThanOneHundredTwentyDaysPastDue  
 FROM  
 (SELECT  
  FusebillId  
  ,ISNULL(CustomerId,'') AS CustomerId  
  ,ISNULL(CustomerName,'') AS CustomerName  
  ,ISNULL(CompanyName,'') AS CompanyName  
  ,ISNULL(DueWithinTerms,0)  
  + ISNULL(ZeroToThirtyDaysPastDue,0)  
  + ISNULL(ThirtyOneToSixtyDaysPastDue,0)  
  +ISNULL(SixtyOneToNinetyDaysPastDue,0)  
  + ISNULL(NinetyOneToOneHundredTwentyDaysPastDue,0)  
  + ISNULL(MoreThanOneHundredTwentyDaysPastDue,0)  
  AS TotalAmountDue  
  ,0 as TotalAmountUnallocated  
  ,InvoiceId  
  ,InvoiceNumber  
  ,PostedTimestamp  
  ,TermId  
  ,DaysDueAfterTerm  
  ,DueDate  
  ,PaymentScheduleCount  
  ,PaymentScheduleId  
  ,NULL as PaymentId  
  ,ISNULL(DueWithinTerms,0) AS 'DueWithinTerms'  
  ,ISNULL(ZeroToThirtyDaysPastDue,0) AS 'ZeroToThirtyDaysPastDue'  
  ,ISNULL(ThirtyOneToSixtyDaysPastDue,0) AS 'ThirtyOneToSixtyDaysPastDue'  
  ,ISNULL(SixtyOneToNinetyDaysPastDue,0) AS 'SixtyOneToNinetyDaysPastDue'  
  ,ISNULL(NinetyOneToOneHundredTwentyDaysPastDue,0) AS 'NinetyOneToOneHundredTwentyDaysPastDue'  
  ,ISNULL(MoreThanOneHundredTwentyDaysPastDue,0) AS 'MoreThanOneHundredTwentyDaysPastDue'  
  ,ROW_NUMBER() OVER (PARTITION BY InvoiceId ORDER BY DaysDueAfterTerm ASC) AS [RowNumber]  
 FROM  
 (  
 SELECT  
  c.Id AS FusebillId  
  ,c.Reference AS CustomerId  
  ,isnull(c.FirstName,'') + ' ' + isnull(c.LastName,'') AS CustomerName  
  ,c.CompanyName  
  ,cpsj.InvoiceId AS InvoiceId  
  ,cpsj.InvoiceNumber  
  ,cpsj.PostedTimestamp  
  ,PaymentSchedule.DaysDueAfterTerm  
  ,PaymentSchedule.Id AS PaymentScheduleId  
  ,NULL as PaymentId  
  ,cpsj.OutstandingBalance AS AmountDue  
  ,COALESCE(cpsj.TermId,bpd.TermId,cbs.TermId) AS TermId  
  ,cpsj.DueDate  
  ,cpsj.PaymentScheduleCount  
  ,Terms  
 FROM  
#CurrentPaymentScheduleJournal cpsj  
  INNER JOIN PaymentSchedule PaymentSchedule  
ON PaymentSchedule.Id = cpsj.PaymentScheduleId  
INNER JOIN Customer c on c.Id = cpsj.CustomerId
  INNER JOIN CustomerBillingSetting cbs ON cbs.Id = cpsj.CustomerId  
  --An all purchase invoice could have no billing period  
  LEFT JOIN BillingPeriod bp ON bp.Id = cpsj.BillingPeriodId  
  LEFT JOIN BillingPeriodDefinition bpd ON bpd.Id = bp.BillingPeriodDefinitionId  
  LEFT JOIN Lookup.InvoiceAgingPeriod aps ON  
  cpsj.DaysOld >= aps.StartDay and  
  cpsj.DaysOld < aps.EndDay and  
  cpsj.StatusId not in (4,5)  
 WHERE  
  c.AccountId = @AccountId    
  AND c.CurrencyId = @CurrencyId  
  AND (@CustomerIdSet = 0 OR c.Id = @CustomerId)
   AND (@ParentIdSet = 0 OR c.ParentId = @ParentId)
   AND (@CompanyNameSet = 0 OR c.CompanyName LIKE '%' + @CompanyName + '%')
   AND (@EmailSet = 0 OR c.PrimaryEmail LIKE '%' + @Email + '%')
   AND (@ReferenceSet = 0 OR c.Reference LIKE '%' + @Reference + '%')
   AND (@StatusSet = 0 OR c.StatusId = @Status)
   AND (@AccountingStatusSet = 0 OR c.AccountStatusId = @AccountingStatus)
 )Data  
 PIVOT  
 (  
  SUM(AmountDue)  
  FOR Terms IN  
  (  
   [DueWithinTerms],[ZeroToThirtyDaysPastDue],[ThirtyOneToSixtyDaysPastDue],[SixtyOneToNinetyDaysPastDue],[NinetyOneToOneHundredTwentyDaysPastDue],[MoreThanOneHundredTwentyDaysPastDue]  
  )  
 )Pivottable  
 )Result  
  INNER JOIN LOOKUP.Term ON Lookup.Term.Id = TermId  
 WHERE  
 TotalAmountDue !=0  
  AND (@CustomerBalanceGtSet = 0 OR TotalAmountDue >= @CustomerBalanceGt)
AND (@CustomerBalanceLtSet = 0 OR TotalAmountDue <= @CustomerBalanceLt)
AND (@AgingBucketSet = 0 OR  (
(@AgingBucket = 'dueWithinTerms' AND DueWithinTerms > 0)
OR (@AgingBucket = 'zeroToThirtyDaysPastDue' AND ZeroToThirtyDaysPastDue > 0)
OR (@AgingBucket = 'thirtyOneToSixtyDaysPastDue' AND ThirtyOneToSixtyDaysPastDue > 0)
OR (@AgingBucket = 'sixtyOneToNinetyDaysPastDue' AND SixtyOneToNinetyDaysPastDue > 0)
OR (@AgingBucket = 'ninetyOneToOneHundredTwentyDaysPastDue' AND NinetyOneToOneHundredTwentyDaysPastDue > 0)
OR (@AgingBucket = 'moreThanOneHundredTwentyDaysPastDue' AND MoreThanOneHundredTwentyDaysPastDue > 0)
)
)

 UNION  
         
 SELECT
FusebillId
 ,'Payment' AS TransactionType  
 ,NULL as InvoiceId  
 ,NULL AS InvoiceNumber  
 ,PostedTimestamp
 ,NULL AS DueDate  
 ,NULL AS PaymentScheduleId  
 ,PaymentId
 ,0 as TotalAmountDue  
 ,TotalAmountUnallocated  
 ,NULL AS Term  
 ,NULL AS [DueWithinTerms]  
 ,NULL AS [ZeroToThirtyDaysPastDue]  
 ,NULL AS [ThirtyOneToSixtyDaysPastDue]  
 ,NULL AS [SixtyOneToNinetyDaysPastDue]  
 ,NULL AS [NinetyOneToOneHundredTwentyDaysPastDue]  
 ,NULL AS [MoreThanOneHundredTwentyDaysPastDue]
FROM
 (
SELECT  
c.Id AS FusebillId  
,t.EffectiveTimestamp AS PostedTimestamp  
,p.id as PaymentId  
,p.UnallocatedAmount + SUM(ISNULL(pn.Amount,0)) + SUM(ISNULL(rft.Amount,0)) AS TotalAmountUnallocated  
FROM Payment p  
INNER JOIN [Transaction] t ON t.Id = p.Id  
INNER JOIN Customer c ON c.Id = t.CustomerId
inner join @CustomerData cd on cd.Id = c.Id
LEFT JOIN PaymentNote pn ON pn.PaymentId = p.Id AND pn.EffectiveTimestamp > @ReportDate
LEFT JOIN Refund rf ON rf.OriginalPaymentId = p.Id
LEFT JOIN [Transaction] rft ON rft.Id = rf.Id AND rft.EffectiveTimestamp > @ReportDate
WHERE t.AccountId = @AccountId  
AND t.EffectiveTimestamp <= @ReportDate  
AND c.CurrencyId = @CurrencyId  
   AND (@CustomerIdSet = 0 OR c.Id = @CustomerId)
   AND (@ParentIdSet = 0 OR c.ParentId = @ParentId)
   AND (@CompanyNameSet = 0 OR c.CompanyName LIKE '%' + @CompanyName + '%')
   AND (@EmailSet = 0 OR c.PrimaryEmail LIKE '%' + @Email + '%')
   AND (@ReferenceSet = 0 OR c.Reference LIKE '%' + @Reference + '%')
   AND (@StatusSet = 0 OR c.StatusId = @Status)
   AND (@AccountingStatusSet = 0 OR c.AccountStatusId = @AccountingStatus)
GROUP BY
c.Id
,t.EffectiveTimestamp
,p.Id
,p.UnallocatedAmount
 ) Payments
 WHERE TotalAmountUnallocated > 0
) AS InvoicesAndPayments  
INNER JOIN Customer c on c.Id = InvoicesAndPayments.FusebillId
WHERE (@CustomerBalanceGtSet = 0 OR TotalAmountDue >= @CustomerBalanceGt)
AND (@CustomerBalanceLtSet = 0 OR TotalAmountDue <= @CustomerBalanceLt)
AND (@AgingBucketSet = 0 OR  (
(@AgingBucket = 'dueWithinTerms' AND DueWithinTerms > 0)
OR (@AgingBucket = 'zeroToThirtyDaysPastDue' AND ZeroToThirtyDaysPastDue > 0)
OR (@AgingBucket = 'thirtyOneToSixtyDaysPastDue' AND ThirtyOneToSixtyDaysPastDue > 0)
OR (@AgingBucket = 'sixtyOneToNinetyDaysPastDue' AND SixtyOneToNinetyDaysPastDue > 0)
OR (@AgingBucket = 'ninetyOneToOneHundredTwentyDaysPastDue' AND NinetyOneToOneHundredTwentyDaysPastDue > 0)
OR (@AgingBucket = 'moreThanOneHundredTwentyDaysPastDue' AND MoreThanOneHundredTwentyDaysPastDue > 0)
)
)

OPTION(RECOMPILE)  

SELECT
rs.[Transaction Type]
,rs.[Invoice ID]
,rs.[Invoice Number]
,rs.[Posted Timestamp]
,rs.[Due Date]
,rs.[Payment Schedule ID]
,rs.[Payment ID]
,rs.[Total Amount Due]
,rs.[Total Amount Unallocated]
,rs.Term
,rs.[Due Within Terms]
,rs.[Zero To Thirty Days Past Due]
,rs.[Thirty-one To Sixty Days Past Due]
,rs.[Sixty-one To Ninety Days Past Due]
,rs.[Ninety-one To One Hundred Twenty Days Past Due]
,[More Than One Hundred Twenty Days Past Due]
, fc.* 
FROM #ResultSet rs 
INNER JOIN FullCustomerDataByAccount(@AccountId, @CurrencyId, @ReportDate) fc on fc.[Fusebill ID] = rs.CustomerId
ORDER BY fc.[Fusebill ID], [Transaction Type], [Posted Timestamp]  

DROP TABLE #ResultSet
DROP TABLE #CurrentPaymentScheduleJournal

GO

