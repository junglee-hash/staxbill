

CREATE PROCEDURE [Reporting].[Maximizer_ARBalance]
	@AccountId bigint
	,@StartDate DATETIME
	,@EndDate DATETIME
AS

set transaction isolation level snapshot

DECLARE @ReportDate datetime = @EndDate

set transaction isolation level snapshot
create table #CustomerBalance
(
CustomerBalance decimal (10,2)
,CustomerId bigint  Primary Key not null
)
insert into #CustomerBalance
Select 
	Sum(ARDEbit)-Sum(ARCredit) as CustomerBalance
	,clj.CustomerId
from 
	vw_CustomerLedgerJournal clj 
	inner join Customer c on c.Id = clj.CustomerId 
 Where 
	COALESCE(clj.EffectiveTimestamp, clj.CreatedTimestamp) < @ReportDate
	and clj.AccountID = @AccountId
Group by 
	clj.CustomerId

create table #CurrentPaymentScheduleJournal
(
PaymentScheduleId bigint primary key not null
,OutstandingBalance decimal(18,2) not null
,DaysOld decimal(20,2) not null
,StatusId int not null
,DueDate DATETIME NOT NULL
)

SELECT 
	ps.Id
INTO #PaymentSchedules
FROM
		PaymentSchedule ps
		inner join Invoice i on ps.InvoiceId = i.Id
		inner join Customer c on c.id = i.CustomerId
WHERE
		i.AccountId = @AccountId
		and c.AccountId = @AccountId

--SELECT * FROM #PaymentSchedules

;WITH CTE_RankedJournals AS (
	SELECT 
		ROW_NUMBER() OVER (PARTITION BY psj.PaymentScheduleId ORDER BY psj.Id DESC) AS [RowNumber]
		, psj.PaymentScheduleId
		, psj.OutstandingBalance
		, cast(datediff( hour,psj.DueDate,@ReportDate) as decimal(20,2))/24 as DaysOld
		, psj.StatusId
		,psj.DueDate
	FROM
		   PaymentScheduleJournal psj
		   INNER JOIN #PaymentSchedules pss ON pss.Id = psj.PaymentScheduleId
			  inner join PaymentSchedule ps
			  on psj.PaymentScheduleId = ps.Id
			  inner join Invoice i
			  on ps.InvoiceId = i.Id
			inner join Customer c on c.id = i.CustomerId
	WHERE
		   psj.CreatedTimestamp < @ReportDate
			  and i.AccountId = @AccountId
			  and c.AccountId = @AccountId
		)
insert into #CurrentPaymentScheduleJournal
SELECT PaymentScheduleId, OutstandingBalance, DaysOld, StatusId, DueDate
FROM CTE_RankedJournals
WHERE [RowNumber] = 1
AND StatusId NOT IN (4,5,7)

--SELECT * FROM #CurrentPaymentScheduleJournal

DROP TABLE #PaymentSchedules

SELECT 
    ISNULL(InvoiceNumber,'') as InvoiceNumber
	,FusebillId
    ,ISNULL(CustomerId,'') as CustomerId
    ,ISNULL(CustomerName,'') as CustomerName
    ,ISNULL(CompanyName,'') as CompanyName
    ,CustomerStatus
	,ISNULL(SalesTrackingCode1,'') as SalesTrackingCode1
	,ISNULL(SalesTrackingCode2,'') as SalesTrackingCode2
	,PostedTimestamp
	,Currency
	,InvoiceAmount
    ,ISNULL(DueWithinTerms,0) 
    + ISNULL(ZeroToThirtyDaysPastDue,0) 
    + ISNULL(ThirtyOneToSixtyDaysPastDue,0) 
    +ISNULL(SixtyOneToNinetyDaysPastDue,0)
    + ISNULL(NinetyOneToOneHundredTwentyDaysPastDue,0) 
    + ISNULL(MoreThanOneHundredTwentyDaysPastDue,0) 
    as TotalAmountDue
	,Term
	,DueDate
	,CustomerBalance
    ,ISNULL(DueWithinTerms,0) as 'DueWithinTerms'
    ,ISNULL(ZeroToThirtyDaysPastDue,0) as 'ZeroToThirtyDaysPastDue'
    ,ISNULL(ThirtyOneToSixtyDaysPastDue,0) as 'ThirtyOneToSixtyDaysPastDue'
    ,ISNULL(SixtyOneToNinetyDaysPastDue,0) as 'SixtyOneToNinetyDaysPastDue'
    ,ISNULL(NinetyOneToOneHundredTwentyDaysPastDue,0) as 'NinetyOneToOneHundredTwentyDaysPastDue'
    ,ISNULL(MoreThanOneHundredTwentyDaysPastDue,0) as 'MoreThanOneHundredTwentyDaysPastDue'
    ,(ISNULL(DueWithinTerms,0) 
    + ISNULL(ZeroToThirtyDaysPastDue,0) 
    + ISNULL(ThirtyOneToSixtyDaysPastDue,0) 
        +ISNULL(SixtyOneToNinetyDaysPastDue,0)
    + ISNULL(NinetyOneToOneHundredTwentyDaysPastDue,0) 
    + ISNULL(MoreThanOneHundredTwentyDaysPastDue,0))-ISNULL(CustomerBalance,0) as AvailableFunds
    ,ISNULL(Phone,'') as Phone
    ,ISNULL(Email,'') as Email
FROM
(
SELECT 
	c.Id as FusebillId 
	,c.Reference as CustomerId
	,isnull(c.FirstName,'') + ' ' + isnull(c.LastName,'') as CustomerName
	,c.CompanyName
	,c.PrimaryPhone as Phone
	,c.PrimaryEmail as Email
	,lcs.Name As CustomerStatus
	,ij.SumOfCharges - ij.SumOfDiscounts + ij.SumOfTaxes as InvoiceAmount
	,cpsj.OutstandingBalance as AmountDue
	,Terms
	,cb.CustomerBalance
	,i.InvoiceNumber
	,i.PostedTimestamp
	,cpsj.DueDate
	,cu.IsoName as Currency
	,ISNULL(tei.Name, tec.Name) as Term
	,stc1.Name as SalesTrackingCode1
	,stc2.Name as SalesTrackingCode2
FROM
	Customer c
	INNER JOIN Lookup.Currency cu ON c.CurrencyId = cu.Id
	INNER JOIN CustomerBillingSetting cbs ON cbs.Id = c.Id
	INNER JOIN Lookup.Term tec ON tec.Id = cbs.TermId
	INNER JOIN CustomerReference cr ON cr.Id = c.Id
	LEFT JOIN SalesTrackingCode stc1 ON stc1.Id = cr.SalesTrackingCode1Id
	LEFT JOIN SalesTrackingCode stc2 ON stc2.Id = cr.SalesTrackingCode2Id
	LEFT JOIN vw_InvoiceSummary isum ON c.Id = isum.CustomerId AND isum.OutstandingBalance > 0
	LEFT JOIN Invoice i on isum.Id = i.Id
	LEFT JOIN Lookup.Term tei ON tei.Id = i.TermId
	LEFT JOIN InvoiceJournal ij ON ij.InvoiceId = i.Id AND ij.IsActive = 1
	LEFT JOIN PaymentSchedule PaymentSchedule on i.Id = PaymentSchedule.InvoiceId
	LEFT JOIN #CurrentPaymentScheduleJournal cpsj on PaymentSchedule.Id = cpsj.PaymentScheduleId
	LEFT JOIN Lookup.InvoiceAgingPeriod aps ON
		cpsj.DaysOld >= aps.StartDay and 
		cpsj.DaysOld < aps.EndDay and 
		cpsj.StatusId not in (4,5)
	INNER JOIN Lookup.CustomerStatus lcs on c.StatusId = lcs.Id
	INNER JOIN #CustomerBalance cb 	on c.Id = cb.CustomerId
WHERE 
	C.AccountId = @AccountId
	AND (
		cpsj.DueDate IS NOT NULL --Outstanding Invoice
		OR 
		cb.CustomerBalance < 0 --Money on Deposit
	)

)Data
PIVOT
(
       MAX(AmountDue)
       for Terms in
       (
              [DueWithinTerms],[ZeroToThirtyDaysPastDue],[ThirtyOneToSixtyDaysPastDue],[SixtyOneToNinetyDaysPastDue],[NinetyOneToOneHundredTwentyDaysPastDue],[MoreThanOneHundredTwentyDaysPastDue]
       )
)Pivottable

ORDER BY InvoiceNumber,DueDate


drop table #CustomerBalance
drop table #CurrentPaymentScheduleJournal

GO

