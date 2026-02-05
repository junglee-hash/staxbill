/*********************************************************************************  
[[usp_getInvoicesAgedByDateSummary]]  
  
  
Inputs:  
@AccountId bigint  
,@ReportDate datetime ='1900-01-01'  
,@SortField varchar (60)  
,@SortOrder varchar (4)  
,@RowStart int = 1  
,@RowEnd int = 20  
  
Work:  
Adds one day to the report date and adjusts for the Accounts Timezone  
Returns open invoices for the account according to the requested Report Date  
Can order by any field that comes back  
  
SAMPLE CALL:  
declare   
       @AccountId bigint = 9  
       ,@ReportDate datetime   
       ,@FilterField varchar (100) = 'TotalAmoun3tDue'  
       ,@FilterOperator char (2) --= '<'  
       ,@FilterValue varchar (20) = '500'  
exec usp_getInvoicesAgedByDateSummary @AccountId, @ReportDate,@FilterField,@FilterOperator,@FilterValue  
  
Outputs:  
  
  
*********************************************************************************/  
-- =============================================  
CREATE   Procedure [dbo].[usp_getInvoicesAgedByDateSummary]  
(--declare  
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
) 
AS  
DECLARE   
       --@UTCReportDate datetime  
       --,  
    @SQL nvarchar (max)  
       ,@ReportFilter nvarchar (300) 
	   ,@PreReportFilter NVARCHAR (300) = ''     
,@PostReportFilter NVARCHAR (300) = '' 
    
If @ReportDate is null    
       SET @ReportDate = GETUTCDATE()    

IF @CustomerIdSet = 1
BEGIN
	Set @PreReportFilter = @PreReportFilter + ' AND c.Id = ' + CONVERT(NVARCHAR,@CustomerId)
END

IF @ParentIdSet = 1
BEGIN
	Set @PreReportFilter = @PreReportFilter + ' AND c.ParentId = ' + CONVERT(NVARCHAR,@ParentId)
END

IF @CompanyNameSet = 1
BEGIN
	Set @PreReportFilter = @PreReportFilter + ' AND c.CompanyName LIKE ''' + @CompanyName + ''''
END

IF @EmailSet = 1
BEGIN
	Set @PreReportFilter = @PreReportFilter + ' AND c.PrimaryEmail LIKE ''' + @Email + ''''
END

IF @ReferenceSet = 1
BEGIN
	Set @PreReportFilter = @PreReportFilter + ' AND c.Reference LIKE ''' + @Reference + ''''
END

IF @StatusSet = 1
BEGIN
	Set @PreReportFilter = @PreReportFilter + ' AND c.StatusId = ' + CONVERT(NVARCHAR,@Status)
END

IF @AccountingStatusSet = 1
BEGIN
	Set @PreReportFilter = @PreReportFilter + ' AND c.AccountStatusId = ' + CONVERT(NVARCHAR,@AccountingStatus)
END

IF @AgingBucketSet = 1
BEGIN
	Set @PostReportFilter = @PostReportFilter + ' AND ' + @AgingBucket + ' > 0'
END

IF @CustomerBalanceGtSet = 1
BEGIN
	Set @PostReportFilter = @PostReportFilter + ' AND TotalAmountDue >= ' + CONVERT(NVARCHAR,@CustomerBalanceGt)
END

IF @CustomerBalanceLtSet = 1
BEGIN
	Set @PostReportFilter = @PostReportFilter + ' AND TotalAmountDue <= ' + CONVERT(NVARCHAR,@CustomerBalanceLt)
END
  

  
    set fmtonly off  


SET @SQL =       
'      
SET TRANSACTION ISOLATION LEVEL SNAPSHOT    
      
CREATE TABLE #CustomerBalance      
(      
 CustomerBalance DECIMAL (18,2)      
 ,CustomerId BIGINT  PRIMARY KEY NOT NULL      
)      
INSERT INTO #CustomerBalance      
SELECT       
 SumDebit-SumCredit AS [CustomerBalance]      
 ,CustomerId      
FROM [dbo].[tvf_CustomerLedgersByLedgerType](@AccountId,@CurrencyId,NULL,@ReportDate,1) cl ' +      
 CASE WHEN @SalesTrackingCodeType IS NOT NULL THEN      
  ' INNER JOIN CustomerReference cr ON cr.Id = cl.CustomerId' ELSE '' END +      
 CASE WHEN @SalesTrackingCodeType = 1 THEN      
	case when @SalesTrackingCodeId is null then ' AND cr.SalesTrackingCode1Id is null' 
		else ' AND cr.SalesTrackingCode1Id = @SalesTrackingCodeId' end 
	ELSE '' END +            
 CASE WHEN @SalesTrackingCodeType = 2 THEN      
	case when @SalesTrackingCodeId is null then ' AND cr.SalesTrackingCode2Id is null' 
		else ' AND cr.SalesTrackingCode2Id = @SalesTrackingCodeId' end 
	ELSE '' END +     
 CASE WHEN @SalesTrackingCodeType = 3 THEN      
	case when @SalesTrackingCodeId is null then ' AND cr.SalesTrackingCode3Id is null' 
		else ' AND cr.SalesTrackingCode3Id = @SalesTrackingCodeId' end 
	ELSE '' END +     
 CASE WHEN @SalesTrackingCodeType = 4 THEN      
	case when @SalesTrackingCodeId is null then ' AND cr.SalesTrackingCode4Id is null' 
		else ' AND cr.SalesTrackingCode4Id = @SalesTrackingCodeId' end 
	ELSE '' END +     
 CASE WHEN @SalesTrackingCodeType = 5 THEN      
	case when @SalesTrackingCodeId is null then ' AND cr.SalesTrackingCode5Id is null' 
		else ' AND cr.SalesTrackingCode5Id = @SalesTrackingCodeId' end 
	ELSE '' END +         
'      
CREATE TABLE #CurrentPaymentScheduleJournal      
(      
 PaymentScheduleId bigint primary key NOT NULL      
 ,OutstandingBalance decimal(18,2) NOT NULL      
 ,DaysOld decimal(20,2) NOT NULL      
 ,StatusId INT NOT NULL      
)      
      
SELECT       
 ps.Id      
INTO #PaymentSchedules      
FROM      
 PaymentSchedule ps      
 INNER JOIN Invoice i ON ps.InvoiceId = i.Id      
 INNER JOIN Customer c ON c.id = i.CustomerId      
WHERE      
   i.AccountId = @AccountId      
   AND c.CurrencyId = @CurrencyId      
   AND c.AccountId = @AccountId   ' +
   ISNULL(@PreReportFilter,'')  + '    
   '

SET @SQL = @SQL + '
;WITH CTE_RankedJournals AS (      
 SELECT       
 ROW_NUMBER() OVER (PARTITION BY psj.PaymentScheduleId ORDER BY psj.CreatedTimestamp DESC, psj.IsActive DESC) AS [RowNumber]      
 , psj.PaymentScheduleId      
 , psj.OutstandingBalance      
 , cast(datediff( hour,psj.DueDate,@ReportDate) AS decimal(20,2))/24 AS DaysOld      
 , psj.StatusId      
 FROM      
    PaymentScheduleJournal psj      
    INNER JOIN #PaymentSchedules pss ON pss.Id = psj.PaymentScheduleId      
    INNER JOIN PaymentSchedule ps      
    on psj.PaymentScheduleId = ps.Id      
    INNER JOIN Invoice i      
    ON ps.InvoiceId = i.Id      
 INNER JOIN Customer c on c.id = i.CustomerId      
 WHERE      
     psj.CreatedTimestamp < @ReportDate      
     and i.AccountId = @AccountId      
     and c.CurrencyId = @CurrencyId      
     and c.AccountId = @AccountId    ' +
	ISNULL(@PreReportFilter,'')  + '    
  )      
INSERT INTO #CurrentPaymentScheduleJournal      
SELECT     
 PaymentScheduleId    
 , OutstandingBalance    
 , DaysOld    
 , StatusId       
FROM CTE_RankedJournals      
WHERE [RowNumber] = 1      
AND StatusId NOT IN (4,5,7)      
      
DROP TABLE #PaymentSchedules      
     
    
SELECT        
 ISNULL(SUM(CustomerBalance),0) as  Balance      
 ,ISNULL(SUM(TotalAmountDue),0) as TotalAmountDue
 ,ISNULL(SUM(DueWithinTerms      ),0) as DueWithinTerms
 ,ISNULL(SUM(ZeroToThirtyDaysPastDue     ),0)  as ZeroToThirtyDaysPastDue
 ,ISNULL(SUM(ThirtyOneToSixtyDaysPastDue   ),0)    as ThirtyOneToSixtyDaysPastDue
 ,ISNULL(SUM(SixtyOneToNinetyDaysPastDue   ),0) as SixtyOneToNinetyDaysPastDue  
 ,ISNULL(SUM(NinetyOneToOneHundredTwentyDaysPastDue   ) ,0) asNinetyOneToOneHundredTwentyDaysPastDue  
 ,ISNULL(SUM(MoreThanOneHundredTwentyDaysPastDue   ),0) as  MoreThanOneHundredTwentyDaysPastDue
 ,ISNULL(SUM(AvailableFunds),0) as AvailableFunds
FROM (SELECT       
 FusebillId        
 ,ISNULL(DueWithinTerms, 0)    
  + ISNULL(ZeroToThirtyDaysPastDue, 0)    
  + ISNULL(ThirtyOneToSixtyDaysPastDue, 0)    
  + ISNULL(SixtyOneToNinetyDaysPastDue, 0)    
  + ISNULL(NinetyOneToOneHundredTwentyDaysPastDue, 0)    
  + ISNULL(MoreThanOneHundredTwentyDaysPastDue, 0)       
  AS TotalAmountDue      
 ,CustomerBalance      
 ,ISNULL(DueWithinTerms, 0) AS ''DueWithinTerms''      
 ,ISNULL(ZeroToThirtyDaysPastDue, 0) AS ''ZeroToThirtyDaysPastDue''      
 ,ISNULL(ThirtyOneToSixtyDaysPastDue, 0) AS ''ThirtyOneToSixtyDaysPastDue''      
 ,ISNULL(SixtyOneToNinetyDaysPastDue, 0) AS ''SixtyOneToNinetyDaysPastDue''      
 ,ISNULL(NinetyOneToOneHundredTwentyDaysPastDue, 0) AS ''NinetyOneToOneHundredTwentyDaysPastDue''      
 ,ISNULL(MoreThanOneHundredTwentyDaysPastDue, 0) AS ''MoreThanOneHundredTwentyDaysPastDue''      
 ,(ISNULL(DueWithinTerms, 0)    
  + ISNULL(ZeroToThirtyDaysPastDue, 0)    
  + ISNULL(ThirtyOneToSixtyDaysPastDue, 0)    
  + ISNULL(SixtyOneToNinetyDaysPastDue, 0)    
  + ISNULL(NinetyOneToOneHundredTwentyDaysPastDue, 0)    
  + ISNULL(MoreThanOneHundredTwentyDaysPastDue, 0)) - ISNULL(CustomerBalance, 0)    
  AS AvailableFunds    
FROM      
(      
SELECT       
 c.Id as FusebillId         
 ,cpsj.OutstandingBalance as AmountDue      
 ,Terms      
 ,cb.CustomerBalance     
from      
 Customer c      
 LEFT JOIN Invoice i ON c.Id = i.CustomerId     
 LEFT JOIN PaymentSchedule PaymentSchedule ON i.Id = PaymentSchedule.InvoiceId      
 LEFT JOIN #CurrentPaymentScheduleJournal cpsj ON PaymentSchedule.Id = cpsj.PaymentScheduleId      
 LEFT JOIN Lookup.InvoiceAgingPeriod aps ON cpsj.DaysOld >= aps.StartDay AND cpsj.DaysOld < aps.EndDay AND cpsj.StatusId NOT IN (4,5)     
 INNER JOIN Lookup.CustomerStatus lcs ON c.StatusId = lcs.Id     
 INNER JOIN #CustomerBalance cb ON c.Id = cb.CustomerId    
WHERE       
 C.AccountId = @AccountId      
 AND C.CurrencyId = @CurrencyId   ' +
   ISNULL(@PreReportFilter,'')  + '    
) Data      
PIVOT      
(      
 SUM(AmountDue)      
 FOR Terms IN      
 (      
  [DueWithinTerms]    
  ,[ZeroToThirtyDaysPastDue]    
  ,[ThirtyOneToSixtyDaysPastDue]    
  ,[SixtyOneToNinetyDaysPastDue]    
  ,[NinetyOneToOneHundredTwentyDaysPastDue]    
  ,[MoreThanOneHundredTwentyDaysPastDue]      
 )      
) Pivottable      
) Result    
WHERE      
 (AvailableFunds != 0      
 OR TotalAmountDue != 0  )'
 SET @SQL = @SQL +  + ISNULL( @PostReportFilter ,'') +'     
       
            
      
OPTION (RECOMPILE)      
      
DROP TABLE #CustomerBalance      
DROP TABLE #CurrentPaymentScheduleJournal'      

--print @sql

EXEC sp_executesql @SQL, N'@AccountId bigint, @ReportDate datetime, @CurrencyId bigint, @SalesTrackingCodeId bigint', @AccountId, @ReportDate, @CurrencyId, @SalesTrackingCodeId

GO

