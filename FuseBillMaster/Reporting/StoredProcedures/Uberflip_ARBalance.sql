
CREATE PROCEDURE [Reporting].[Uberflip_ARBalance]
--declare
	@AccountId BIGINT --= 10
	,@StartDate DATETIME-- = '2016-01-01'
	,@EndDate DATETIME-- = '2018-01-01'
AS
BEGIN


set nocount on
set transaction isolation level snapshot

DECLARE @TimezoneId BIGINT

SELECT @StartDate = dbo.fn_GetUtcTime(@StartDate, TimezoneId)
	,@EndDate = dbo.fn_GetUtcTime(@EndDate, TimezoneId)
	,@TimezoneId = TimezoneId
FROM AccountPreference
WHERE Id = @AccountId


DECLARE @UTCReportDateTime datetime = @EndDate
DECLARE @CurrencyId bigint = 1

SELECT * INTO #CustomerData
FROM dbo.FullCustomerDataByAccount(@AccountId, @CurrencyId, @UTCReportDateTime)

ALTER TABLE #CustomerData
DROP COLUMN [Customer Parent Id]


create table #CustomerBalance
(
CustomerBalance decimal (10,2)
,CustomerId bigint  Primary Key not null
)
insert into #CustomerBalance
SELECT 
	SumDebit-SumCredit AS [CustomerBalance]
	,CustomerId
FROM [dbo].[tvf_CustomerLedgersByLedgerType](@AccountId,@CurrencyId,NULL,@UTCReportDateTime,1) cl

create table #CurrentPaymentScheduleJournal
(
PaymentScheduleId bigint primary key not null
,PaymentScheduleJournalId bigint
)
insert into #CurrentPaymentScheduleJournal
SELECT
       PaymentScheduleId as PaymentScheduleId
       ,max(psj.Id) as  PaymentScheduleJournalId
FROM
       PaymentScheduleJournal psj
          inner join PaymentSchedule ps
          on psj.PaymentScheduleId = ps.Id
          inner join Invoice i
          on ps.InvoiceId = i.Id
WHERE
       psj.CreatedTimestamp < @UTCReportDateTime
          and
          i.AccountId = @AccountId
GROUP BY
       PaymentScheduleId

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
              on cast(datediff( hour,PaymentScheduleJournal.DueDate,@UTCReportDateTime) as decimal(20,2))/24>= aps.StartDay
              and cast(datediff( hour,PaymentScheduleJournal.DueDate,@UTCReportDateTime) as decimal(20,2))/24 < aps.EndDay
          and PaymentScheduleJournal.StatusId not in (4,5)
 group by
   c.Id 
 )

SELECT  
		CustomerId
	    ,CustomerBalance as  Balance
       ,TotalAmountDue
       ,DueWithinTerms
       ,ZeroToThirtyDaysPastDue
       ,ThirtyOneToSixtyDaysPastDue
       ,SixtyOneToNinetyDaysPastDue
       ,NinetyOneToOneHundredTwentyDaysPastDue
       ,MoreThanOneHundredTwentyDaysPastDue
       ,AvailableFunds
	   ,Currency
	   ,[NetTerms]
	   ,DaysUntilSuspension
	   ,DueDate
	   ,PaymentMethod
INTO #Results
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
	   ,PaymentMethod
FROM
(
SELECT 
		c.Id as CustomerId
	  ,PaymentScheduleJournal.OutstandingBalance as AmountDue
       ,Terms
      ,CustomerBalance
	  ,cur.ISOName as Currency
	  ,Lookup.Term.Name as [NetTerms]
	  ,CASE WHEN cj.StatusId = 2 AND csj.StatusId = 2 THEN (isnull(cbs.CustomerGracePeriod, isnull(bp.AccountGracePeriod, 0)) + isnull(cbs.GracePeriodExtension, 0) - (DATEDIFF(hh, 
                      cj.CreatedTimestamp, GETUTCDATE()) / 24)) ELSE 0 END AS DaysUntilSuspension
	  ,MinDueDates.[DueDate] as [DueDate]
	  ,CASE WHEN (cbs.AutoCollect = 1 OR
                         (cbs.AutoCollect IS NULL AND bp.DefaultAutoCollect = 1)) AND pm.Id IS NULL THEN 'Missing' WHEN (cbs.AutoCollect = 1 OR
                         (cbs.AutoCollect IS NULL AND bp.DefaultAutoCollect = 1)) AND pm.Id IS NOT NULL AND pm.PaymentMethodTypeId = 3 THEN 'Credit Card' WHEN (cbs.AutoCollect = 1 OR
                         (cbs.AutoCollect IS NULL AND bp.DefaultAutoCollect = 1)) AND pm.Id IS NOT NULL AND pm.PaymentMethodTypeId = 5 THEN 'ACH' WHEN (cbs.AutoCollect = 1 OR
                         (cbs.AutoCollect IS NULL AND bp.DefaultAutoCollect = 1)) AND pm.Id IS NOT NULL AND pm.PaymentMethodTypeId = 6 THEN 'Paypal' WHEN (cbs.AutoCollect = 0 OR
                         (cbs.AutoCollect IS NULL AND bp.DefaultAutoCollect = 0)) AND pm.Id IS NOT NULL THEN 'AR - Pay method on file' WHEN pm.Id IS NULL THEN 'AR' END AS PaymentMethod
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
              on cast(datediff( hour,PaymentScheduleJournal.DueDate,@UTCReportDateTime) as decimal(20,2))/24>= aps.StartDay
              and cast(datediff( hour,PaymentScheduleJournal.DueDate,@UTCReportDateTime) as decimal(20,2))/24 < aps.EndDay
          and PaymentScheduleJournal.StatusId not in (4,5)
      inner join #CustomerBalance cb
		on c.Id = cb.CustomerId
		left join CustomerBillingSetting cbs
		on c.Id = cbs.Id
		left join Lookup.Term
		on cbs.TermId = Lookup.Term.Id
		inner join CustomerAccountStatusJournal cj
		on cj.CustomerId = c.Id  AND cj.IsActive = 1
		INNER JOIN dbo.CustomerStatusJournal AS csj 
		ON c.Id = csj.CustomerId AND csj.IsActive = 1
		INNER JOIN dbo.AccountBillingPreference AS bp 
		ON c.AccountId = bp.Id
		left join MinDueDates on MinDueDates.Id = c.Id
		left join [dbo].[PaymentMethod] pm on pm.Id = cbs.DefaultPaymentMethodId
		
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

where
AvailableFunds !=0
or
TotalAmountDue !=0 
--option(maxdop 1);

SELECT
	Customer.*
	  ,Balance
       ,TotalAmountDue
       ,DueWithinTerms
       ,ZeroToThirtyDaysPastDue
       ,ThirtyOneToSixtyDaysPastDue
       ,SixtyOneToNinetyDaysPastDue
       ,NinetyOneToOneHundredTwentyDaysPastDue
       ,MoreThanOneHundredTwentyDaysPastDue
       ,AvailableFunds
	   ,Currency
	   ,[NetTerms]
	   ,DaysUntilSuspension
	   ,DueDate
	   ,PaymentMethod
FROM #Results r
INNER JOIN #CustomerData Customer ON Customer.[Fusebill ID] = r.CustomerId

drop table #Results
drop table #CustomerData
drop table #CustomerBalance
drop table #CurrentPaymentScheduleJournal


END

GO

