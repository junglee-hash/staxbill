
CREATE PROCEDURE [dbo].[usp_ARRevenueReportCSV]    
(    
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
    
SET TRANSACTION ISOLATION LEVEL SNAPSHOT    
    
--Temp table to customer details    
SELECT * INTO #CustomerData    
FROM BasicCustomerDataByAccount(@AccountId) bc join Customer c on bc.[Fusebill ID] = c.Id
WHERE 
	(@CustomerIdSet = 0 OR c.Id = @CustomerId)
   AND (@ParentIdSet = 0 OR c.ParentId = @ParentId)
   AND (@CompanyNameSet = 0 OR c.CompanyName LIKE '%' + @CompanyName + '%')
   AND (@EmailSet = 0 OR c.PrimaryEmail LIKE '%' + @Email + '%')
   AND (@ReferenceSet = 0 OR c.Reference LIKE '%' + @Reference + '%')
   AND (@StatusSet = 0 OR c.StatusId = @Status)
   AND (@AccountingStatusSet = 0 OR c.AccountStatusId = @AccountingStatus)
    
DECLARE     
 @SQL nvarchar (max)    
    
create table #CustomerBalance    
(    
CustomerBalance decimal (18,2)    
,CustomerId bigint  Primary Key not null    
)    
    
set @SQL =     
'    
INSERT into #CustomerBalance    
SELECT     
 SumDebit-SumCredit AS [CustomerBalance]    
 ,CustomerId    
FROM [dbo].[tvf_CustomerLedgersByLedgerType](@AccountId,@CurrencyId,NULL,@UTCReportDateTime,1) cl ' +    
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
	ELSE '' END    
    
exec sp_executesql @SQL, N'@AccountId bigint ,@UTCReportDateTime datetime ,@CurrencyId bigint, @SalesTrackingCodeId bigint',@AccountId,@ReportDate,@CurrencyId, @SalesTrackingCodeId --with recompile    
    
create table #CurrentPaymentScheduleJournal    
(    
PaymentScheduleId bigint primary key not null    
,PaymentScheduleJournalId bigint    
)    
insert into #CurrentPaymentScheduleJournal    
SELECT    
       ps.Id as PaymentScheduleId    
       ,j.Id as  PaymentScheduleJournalId    
FROM PaymentSchedule ps    
CROSS APPLY (    
 SELECT TOP 1 Id    
 FROM PaymentScheduleJournal psj    
 WHERE psj.PaymentScheduleId = ps.Id    
 AND psj.CreatedTimestamp < @ReportDate    
 ORDER BY psj.CreatedTimestamp DESC, psj.IsActive DESC    
 ) j    
WHERE EXISTS (    
 SELECT *    
 FROM Invoice i     
  INNER JOIN Customer c ON c.id = i.CustomerId      
WHERE      
  ps.InvoiceId = i.Id    
 AND i.AccountId = @AccountId        
   AND c.CurrencyId = @CurrencyId      
   AND c.AccountId = @AccountId  
   AND (@CustomerIdSet = 0 OR i.CustomerId = @CustomerId)
   AND (@ParentIdSet = 0 OR c.ParentId = @ParentId)
   AND (@CompanyNameSet = 0 OR c.CompanyName LIKE '%' + @CompanyName + '%')
   AND (@EmailSet = 0 OR c.PrimaryEmail LIKE '%' + @Email + '%')
   AND (@ReferenceSet = 0 OR c.Reference LIKE '%' + @Reference + '%')
   AND (@StatusSet = 0 OR c.StatusId = @Status)
   AND (@AccountingStatusSet = 0 OR c.AccountStatusId = @AccountingStatus)
 )    
    
;with MinDueDates as(    
select    
   c.Id,    
   Min(PaymentScheduleJournal.DueDate) as [DueDate]    
from    
Customer c    
       left join CustomerAddressPreference cap    
       on c.Id = cap.Id    
       inner join Lookup.Currency cur    
          on c.CurrencyId = cur.Id    
       left join Invoice i     
       on c.id = i.CustomerId    
       left join PaymentSchedule PaymentSchedule    
       on i.Id = PaymentSchedule.InvoiceId    
       left join #CurrentPaymentScheduleJournal    
       on PaymentSchedule.Id = #CurrentPaymentScheduleJournal.PaymentScheduleId    
       left join PaymentScheduleJournal    
       on #CurrentPaymentScheduleJournal.PaymentScheduleJournalId = PaymentScheduleJournal.id     
              left join lookup.InvoiceAgingPeriod aps    
              on cast(datediff( hour,PaymentScheduleJournal.DueDate,@ReportDate) as decimal(20,2))/24>= aps.StartDay    
              and cast(datediff( hour,PaymentScheduleJournal.DueDate,@ReportDate) as decimal(20,2))/24 < aps.EndDay    
          and PaymentScheduleJournal.StatusId not in (4,5)    
group by    
   c.Id     
 )    
    
SELECT      
       CustomerBalance as  Balance    
       ,TotalAmountDue as [Total Amount Due]    
       ,DueWithinTerms as [Due Within Terms]    
       ,ZeroToThirtyDaysPastDue as [Zero To Thirty Days Past Due]    
       ,ThirtyOneToSixtyDaysPastDue as [Thirty One To Sixty Days Past Due]    
       ,SixtyOneToNinetyDaysPastDue as [Sixty One To Ninety Days Past Due]    
       ,NinetyOneToOneHundredTwentyDaysPastDue as [Ninety One To One Hundred Twenty Days Past Due]    
       ,MoreThanOneHundredTwentyDaysPastDue as [More Than One Hundred Twenty Days Past Due]    
       ,AvailableFunds as [Available Funds]    
    ,Currency    
    ,DueDate as [Earliest Due Date]    
          ,[NetTerms]    
          ,DaysUntilSuspension    
  ,collectionNote.[Most Recent Note]    
  ,collectionNote.[Most Recent Note Author]    
  ,collectionNote.[Most Recent Note Date]    
  ,Customer.*    
FROM        
(SELECT     
              CustomerId    
       ,ISNULL(DueWithinTerms,0)     
       + ISNULL(ZeroToThirtyDaysPastDue,0)     
       + ISNULL(ThirtyOneToSixtyDaysPastDue,0)     
          +ISNULL(SixtyOneToNinetyDaysPastDue,0)    
       + ISNULL(NinetyOneToOneHundredTwentyDaysPastDue,0)     
       + ISNULL(MoreThanOneHundredTwentyDaysPastDue,0)     
       as TotalAmountDue    
       ,ISNULL(DueWithinTerms,0) as DueWithinTerms    
       ,ISNULL(ZeroToThirtyDaysPastDue,0) as ZeroToThirtyDaysPastDue    
       ,ISNULL(ThirtyOneToSixtyDaysPastDue,0) as ThirtyOneToSixtyDaysPastDue    
       ,ISNULL(SixtyOneToNinetyDaysPastDue,0) as SixtyOneToNinetyDaysPastDue    
       ,ISNULL(NinetyOneToOneHundredTwentyDaysPastDue,0) as NinetyOneToOneHundredTwentyDaysPastDue    
       ,ISNULL(MoreThanOneHundredTwentyDaysPastDue,0) as MoreThanOneHundredTwentyDaysPastDue    
       ,(ISNULL(DueWithinTerms,0)     
       + ISNULL(ZeroToThirtyDaysPastDue,0)     
       + ISNULL(ThirtyOneToSixtyDaysPastDue,0)     
          +ISNULL(SixtyOneToNinetyDaysPastDue,0)    
       + ISNULL(NinetyOneToOneHundredTwentyDaysPastDue,0)     
       + ISNULL(MoreThanOneHundredTwentyDaysPastDue,0))-ISNULL(CustomerBalance,0) as AvailableFunds    
          ,Currency    
          ,CustomerBalance    
          ,[NetTerms]    
          ,DaysUntilSuspension    
          ,[DueDate]    
FROM    
(    
SELECT     
              c.Id as CustomerId    
         ,PaymentScheduleJournal.OutstandingBalance as AmountDue    
       ,Terms    
      ,CustomerBalance    
         ,cur.ISOName as Currency    
         ,Lookup.Term.Name as [NetTerms]    
         ,CASE WHEN bp.AutoSuspendEnabled = 1 AND casj.StatusId = 2 AND c.StatusId = 2 THEN (isnull(cbs.CustomerGracePeriod, isnull(bp.AccountGracePeriod, 0)) + isnull(cbs.GracePeriodExtension, 0) - (DATEDIFF(hh,    
                              casj.EffectiveTimestamp, GETUTCDATE()) / 24)) ELSE NULL END AS DaysUntilSuspension    
         ,MinDueDates.[DueDate] as [DueDate]    
FROM Customer c    
INNER JOIN CustomerAccountStatusJournal casj ON casj.CustomerId = c.Id AND casj.IsActive = 1    
inner join Lookup.Currency cur    
    on c.CurrencyId = cur.Id    
left join Invoice i     
on c.id = i.CustomerId    
left join PaymentSchedule PaymentSchedule    
on i.Id = PaymentSchedule.InvoiceId    
left join #CurrentPaymentScheduleJournal    
on PaymentSchedule.Id = #CurrentPaymentScheduleJournal.PaymentScheduleId    
left join PaymentScheduleJournal    
on #CurrentPaymentScheduleJournal.PaymentScheduleJournalId = PaymentScheduleJournal.id     
left join lookup.InvoiceAgingPeriod aps    
 on cast(datediff( hour,PaymentScheduleJournal.DueDate,@ReportDate) as decimal(20,2))/24>= aps.StartDay    
 and cast(datediff( hour,PaymentScheduleJournal.DueDate,@ReportDate) as decimal(20,2))/24 < aps.EndDay    
 and PaymentScheduleJournal.StatusId not in (4,5)    
inner join #CustomerBalance cb    
    on c.Id = cb.CustomerId    
left join CustomerBillingSetting cbs    
on c.Id = cbs.Id    
left join Lookup.Term    
on cbs.TermId = Lookup.Term.Id    
INNER JOIN dbo.AccountBillingPreference AS bp     
ON c.AccountId = bp.Id    
left join MinDueDates on MinDueDates.Id = c.Id    
WHERE     
       C.AccountId = @AccountId    
       AND    
       C.CurrencyId = @CurrencyId       
           
)Data    
PIVOT    
(    
       Sum(AmountDue)    
       for Terms in    
       (    
              [DueWithinTerms],[ZeroToThirtyDaysPastDue],[ThirtyOneToSixtyDaysPastDue],[SixtyOneToNinetyDaysPastDue],[NinetyOneToOneHundredTwentyDaysPastDue],[MoreThanOneHundredTwentyDaysPastDue]    
       )    
)Pivottable    
)AS RowConstrainedResult    
INNER JOIN #CustomerData Customer ON Customer.[Fusebill ID] = RowConstrainedResult.CustomerId    
LEFT JOIN (SELECT cn.[Id],     
cn.[CustomerId],     
CASE    
 WHEN cr.UserId IS NULL THEN  'Support User'    
    WHEN cr.Username IS NOT NULL THEN cr.Username    
    WHEN u.Email IS NOT NULL THEN u.Email    
    ELSE u.FirstName + ' ' + u.LastName    
END as [Most Recent Note Author],     
cn.[UserId],     
cn.[CreatedTimestamp] as [Most Recent Note Date],    
isnull(cn.[Content],'') as [Most Recent Note]    
FROM CollectionNote cn    
INNER JOIN (    
            SELECT MAX(cn.Id) as CollectionNoteId    
            FROM CollectionNote cn    
   inner join Customer c on c.id = cn.CustomerId    
   Where c.AccountId = @AccountId    
            GROUP BY cn.CustomerId) t1 ON t1.CollectionNoteId = cn.Id   
     
   LEFT OUTER JOIN [Credential] cr on cr.UserId = cn.UserId  
   INNER JOIN [User] u on u.Id = cn.userId    
) collectionNote ON collectionNote.CustomerId = RowConstrainedResult.[CustomerId]    
    
where    
(AvailableFunds !=0    
or    
TotalAmountDue !=0)
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
OPTION (RECOMPILE)    
    
DROP TABLE #CustomerBalance    
DROP TABLE #CurrentPaymentScheduleJournal    
DROP TABLE #CustomerData

GO

