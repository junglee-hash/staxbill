CREATE PROCEDURE [dbo].[usp_getInvoicesAgedByDateByCustomer]
	@CustomerId BIGINT
	,@ReportDate DATETIME
AS 

create table #CurrentPaymentScheduleJournal
(
PaymentScheduleId bigint primary key not null
,OutstandingBalance decimal(18,2) not null
,DaysOld decimal(20,2) not null
,StatusId int not null
,DueDate DATETIME NOT NULL
,InvoiceId BIGINT NOT NULL
,PaymentScheduleCount INT NOT NULL
)

SELECT 
	ps.Id
INTO #PaymentSchedules
FROM
	PaymentSchedule ps
	inner join Invoice i on ps.InvoiceId = i.Id
WHERE
	i.CustomerId = @CustomerId

;WITH CTE_RankedJournals AS (
	SELECT
		ROW_NUMBER() OVER (PARTITION BY psj.PaymentScheduleId ORDER BY psj.CreatedTimestamp DESC, psj.IsActive DESC) AS [RowNumber]
		, psj.PaymentScheduleId
		, psj.OutstandingBalance
		, cast(datediff(hour,psj.DueDate,@ReportDate) AS DECIMAL(20,2))/24 AS DaysOld
		, psj.StatusId
		,psj.DueDate
		,ps.InvoiceId
	FROM
		PaymentScheduleJournal psj
		INNER JOIN #PaymentSchedules pss ON pss.Id = psj.PaymentScheduleId
		inner join PaymentSchedule ps
		ON psj.PaymentScheduleId = ps.Id
		INNER JOIN Invoice i
		ON ps.InvoiceId = i.Id
	WHERE
		psj.CreatedTimestamp < @ReportDate
		AND i.CustomerId = @CustomerId
		)
INSERT INTO #CurrentPaymentScheduleJournal
SELECT PaymentScheduleId, OutstandingBalance, DaysOld, StatusId, DueDate, InvoiceId, 1--PaymentScheduleCount
FROM CTE_RankedJournals
WHERE [RowNumber] = 1
	--Need all statuses in case there are multiple payment schedules for an invoice
	--AND StatusId NOT IN (4,5,7)

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

--Only need the extra statuses when there are multiple payment schedules
DELETE FROM #CurrentPaymentScheduleJournal
WHERE PaymentScheduleCount = 1 AND StatusId IN (4,5,7)

DROP TABLE #PaymentSchedules

SELECT TOP(100) * 
FROM (
	SELECT
		'Invoice' AS TransactionType
		,FusebillId
		,CustomerId
		,CustomerName
		,CompanyName
		,CustomerStatus
		,InvoiceId
		,CONVERT(VARCHAR,InvoiceNumber) + CASE WHEN PaymentScheduleCount > 1 THEN '-' + CONVERT(VARCHAR,RowNumber) ELSE + '' END AS InvoiceNumber
		,PostedTimestamp
		,DueDate
		,PaymentScheduleId
		,TotalAmountDue
		,TotalAmountUnallocated
		,TermId
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
		,CustomerStatus
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
		,lcs.Name AS CustomerStatus
		,i.Id AS InvoiceId
		,i.InvoiceNumber
		,i.PostedTimestamp
		,PaymentSchedule.DaysDueAfterTerm
		,PaymentSchedule.Id AS PaymentScheduleId
		,cpsj.OutstandingBalance AS AmountDue
		,COALESCE(i.TermId,bpd.TermId,cbs.TermId) AS TermId
		,cpsj.DueDate
		,cpsj.PaymentScheduleCount
		,Terms
	FROM
		Customer c
		INNER JOIN Invoice i 
		ON c.Id = i.CustomerId
		INNER JOIN PaymentSchedule PaymentSchedule
		ON i.Id = PaymentSchedule.InvoiceId
		INNER JOIN #CurrentPaymentScheduleJournal cpsj
		ON PaymentSchedule.Id = cpsj.PaymentScheduleId
		INNER JOIN CustomerBillingSetting cbs ON cbs.Id = c.Id
		--An all purchase invoice could have no billing period
		LEFT JOIN BillingPeriod bp ON bp.Id = i.BillingPeriodId
		LEFT JOIN BillingPeriodDefinition bpd ON bpd.Id = bp.BillingPeriodDefinitionId
		LEFT JOIN Lookup.InvoiceAgingPeriod aps ON
		cpsj.DaysOld >= aps.StartDay and 
		cpsj.DaysOld < aps.EndDay and 
		cpsj.StatusId not in (4,5)
		INNER JOIN Lookup.CustomerStatus lcs
		ON c.StatusId = lcs.Id
	WHERE 
		c.Id = @CustomerId   
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
	WHERE
	TotalAmountDue !=0

	UNION 
       
	SELECT
		'Payment' AS TransactionType
		,c.Id AS FusebillId
		,ISNULL(c.Reference,'') AS CustomerId
		,ISNULL(c.FirstName,'') + ' ' + ISNULL(c.LastName,'') AS CustomerName
		,ISNULL(CompanyName,'') AS CompanyName
		,lcs.Name AS CustomerStatus
		,p.Id as InvoiceId
		,CONVERT(VARCHAR,p.Id) AS InvoiceNumber
		,t.EffectiveTimestamp AS PostedTimestamp
		,NULL AS DueDate
		,NULL AS PaymentScheduleId
		,0 as TotalAmountDue
		,p.UnallocatedAmount AS TotalAmountUnallocated
		,NULL AS TermId
		,NULL AS [DueWithinTerms]
		,NULL AS [ZeroToThirtyDaysPastDue]
		,NULL AS [ThirtyOneToSixtyDaysPastDue]
		,NULL AS [SixtyOneToNinetyDaysPastDue]
		,NULL AS [NinetyOneToOneHundredTwentyDaysPastDue]
		,NULL AS [MoreThanOneHundredTwentyDaysPastDue]
	FROM Payment p
		INNER JOIN [Transaction] t ON t.Id = p.Id
		INNER JOIN Customer c ON c.Id = t.CustomerId
		INNER JOIN Lookup.CustomerStatus lcs ON c.StatusId = lcs.Id
	WHERE p.UnallocatedAmount > 0
		AND t.CustomerId = @CustomerId
		AND t.EffectiveTimestamp <= @ReportDate
) AS InvoicesAndPayments

drop table #CurrentPaymentScheduleJournal

GO

