CREATE PROCEDURE [dbo].[usp_GenerateMrrFactSubscriptionData]
	@AccountId bigint
	, @CustomerId bigint = null
	, @StartDate date
	, @EndDate date
AS

CREATE TABLE #SubscriptionDeltasByDay (
	SubscriptionProductId bigint,
	RecordDate datetime,
	SpjId bigint
)

;with MaxIdForDate as 
(
Select 
	MAX(spj.Id) as MaxId
	,SubscriptionProductId
	,CONVERT(date,dbo.fn_GetTimezoneTime (spj.CreatedTimestamp,ap.TimezoneId )) as RecordDate
from 
	SubscriptionProductJournal spj with (nolock)
	inner join SubscriptionProduct sp with (nolock)	on spj.SubscriptionProductId = sp.Id AND sp.IsRecurring = 1
	inner join Subscription s with (nolock)	on sp.SubscriptionId = s.Id 
	inner join customer c with (nolock)	on s.CustomerId = c.Id AND c.AccountId = @AccountId
		AND c.Id = ISNULL(@CustomerId, c.Id) -- filter to specific customer
	inner join AccountPreference ap with (nolock) on c.AccountId = ap.Id 
Where
	--CONVERT(date, dbo.fn_GetTimezoneTime (spj.CreatedTimestamp,ap.TimezoneId )) >= @StartDate AND
	CONVERT(date, dbo.fn_GetTimezoneTime (spj.CreatedTimestamp,ap.TimezoneId )) < @EndDate
group by 
	SubscriptionProductId
	,CONVERT(date,dbo.fn_GetTimezoneTime (spj.CreatedTimestamp,ap.TimezoneId))
)
INSERT INTO #SubscriptionDeltasByDay
SELECT sp.Id, d.FullDate, MAX(mi.MaxId) as SpjId
FROM SubscriptionProduct sp with (nolock)
INNER JOIN Subscription s with (nolock) ON s.Id = sp.SubscriptionId AND s.ActivationTimestamp < @EndDate
INNER JOIN Customer c with (nolock) ON c.Id = s.CustomerId AND c.AccountId = @AccountId
	AND c.Id = ISNULL(@CustomerId, c.Id) -- filter to specific customer
INNER JOIN Reporting.[Date] d with (nolock) ON 
	d.FullDate >= DATEADD(day, -1, @StartDate) -- include 1 extra day for date comparison purposes, will be excluded at end of process
	AND d.FullDate < @EndDate
INNER JOIN MaxIdForDate mi ON sp.Id = mi.SubscriptionProductId AND mi.RecordDate <= d.FullDate
WHERE sp.IsRecurring = 1
GROUP BY sp.Id, d.FullDate
ORDER BY sp.Id, d.FullDate

--SELECT * FROM #SubscriptionDeltasByDay

CREATE TABLE #DailySubscriptionData (
	RecordDate date
	, GrossMrr money
	, NetMrr money
	, CurrentGrossMrr money
	, CurrentNetMrr money
	, ActivationDate date
	, CancellationDate date
	, CustomerId bigint
	, SubscriptionId bigint
	, SubscriptionProductId bigint
	, [CurrencyId] bigint not null
	, [PlanId] bigint not null
	, [ProductID] bigint not null
	, [SubscriptionStatusID] int not null
	, [SubscriptionProductIncludedStatus] varchar(50) not null
	, [SubscriptionProductQuantity] decimal(18,6) not null
	, [SubscriptionProductAmount] decimal(18,2) not null
	, [SubscriptionContractStartTimestamp] date not null
	, [SubscriptionContractEndTimestamp] date not null
	, [SubscriptionContractValue] decimal(18,2) not null
	, [SubscriptionContractDurationInMonths] int not null
	, [SalesTrackingCode1Id] bigint not null
	, [SalesTrackingCode2Id] bigint not null
	, [SalesTrackingCode3Id] bigint not null
	, [SalesTrackingCode4Id] bigint not null
	, [SalesTrackingCode5Id] bigint not null
	, [TimezoneId] int not null
)

INSERT INTO #DailySubscriptionData
SELECT 
	delta.RecordDate
	, ISNULL(spj.SubscriptionProductGrossMRR, 0)
	, ISNULL(spj.SubscriptionProductNetMRR, 0)
	, ISNULL(spj.SubscriptionProductCurrentMrr, 0)
	, ISNULL(spj.SubscriptionProductCurrentNetMrr, 0)
	, s.ActivationTimestamp
	, ISNULL(s.CancellationTimestamp, '1900-01-01')
	, s.CustomerId
	, s.Id as SubscriptionId
	, sp.Id as SubscriptionProduct
	, c.CurrencyId
	, s.PlanId
	, sp.ProductId
	, s.StatusId as SubscriptionStatusId
	, CASE WHEN sp.Included = 1 THEN 'Included' ELSE 'Not Included' END
	, ISNULL(spj.SubscriptionProductQuantity, sp.Quantity)
	, ISNULL(spj.SubscriptionProductAmount, sp.Amount)
	, ISNULL(CONVERT(date,dbo.fn_GetTimezoneTime(spj.SubscriptionContractStartTimestamp, ap.TimezoneId )),'1900-01-01') as [Subscription Contract Start Timestamp]
	, ISNULL(CONVERT(date,dbo.fn_GetTimezoneTime(spj.SubscriptionContractEndTimestamp, ap.TimezoneId )),'1900-01-01') as [Subscription Contract End Timestamp]
	, CAST(0 as decimal(18,2)) as ContractValue
	, ISNULL(DATEDIFF(month,s.ContractStartTimestamp,s.ContractEndTimestamp),0) as [Subscription Contract Duration In Months]
	, ISNULL(spj.SalesTrackingcode1Id,-1) as[Sales Tracking Code 1 Id] 
	, ISNULL(spj.SalesTrackingcode2Id,-1) as[Sales Tracking Code 2 Id] 
	, ISNULL(spj.SalesTrackingcode3Id,-1) as[Sales Tracking Code 3 Id] 
	, ISNULL(spj.SalesTrackingcode4Id,-1) as[Sales Tracking Code 4 Id] 
	, ISNULL(spj.SalesTrackingcode5Id,-1) as[Sales Tracking Code 5 Id] 
	, CAST(ap.timezoneid as int)  as TimezoneId
FROM #SubscriptionDeltasByDay delta
INNER JOIN SubscriptionProduct sp ON sp.Id = delta.SubscriptionProductId
INNER JOIN Subscription s ON s.Id = sp.SubscriptionId
INNER JOIN Customer c ON c.Id = s.CustomerId
INNER JOIN AccountPreference ap ON ap.Id = c.AccountId
INNER JOIN SubscriptionProductJournal spj ON spj.Id = delta.SpjId
ORDER BY s.CustomerId, s.Id, sp.Id, delta.RecordDate

--SELECT * FROM #DailySubscriptionData

CREATE TABLE #MrrData (
	[Report Date] date not null
	, [AccountId] bigint not null
	, [CurrencyId] bigint not null
	, [Plan Id] bigint not null
	, [Product ID] bigint not null
	, [Customer ID] bigint not null
	, [Subscription ID] bigint not null
	, [Subscription Product ID] bigint not null
	, [Subscription Status ID] int not null
	, [Subscription Product Included Status] varchar(50) not null
	, [Subscription Product Quantity] decimal(18,6) not null
	, [Subscription Product Amount] decimal(18,2) not null
	, [Subscription Product Gross Monthly Recurring Revenue] decimal(18,2) not null
	, [Subscription Product Net Monthly Recurring Revenue] decimal(18,2) not null
	, [Subscription Product Net New MRR] decimal(18,2) not null
	, [Subscription Product Net Expansion MRR] decimal(18,2) not null
	, [Subscription Product Net Lost MRR] decimal(18,2) not null
	, [Subscription Product Net Contraction MRR] decimal(18,2) not null
	, [Subscription Product Gross New MRR] decimal(18,2) not null
	, [Subscription Product Gross Expansion MRR] decimal(18,2) not null
	, [Subscription Product Gross Lost MRR] decimal(18,2) not null
	, [Subscription Product Gross Contraction MRR] decimal(18,2) not null
	, [Subscription Contract Start Timestamp] date not null
	, [Subscription Contract End Timestamp] date not null
	, [Subscription Contract Value] decimal(18,2) not null
	, [Subscription Contract Duration In Months] int not null
	, [Sales Tracking Code 1 Id] bigint not null
	, [Sales Tracking Code 2 Id] bigint not null
	, [Sales Tracking Code 3 Id] bigint not null
	, [Sales Tracking Code 4 Id] bigint not null
	, [Sales Tracking Code 5 Id] bigint not null
	, [TimezoneId] int not null
	, [Subscription Product Gross Current MRR] decimal(18,2)
	, [Subscription Product Net Current MRR] decimal(18,2)
	, [Subscription Product Gross New Current MRR] decimal(18,2)
	, [Subscription Product Gross Growth Current MRR] decimal(18,2)
	, [Subscription Product Gross Churn Current MRR] decimal(18,2)
	, [Subscription Product Gross Contraction Current MRR] decimal(18,2)
	, [Subscription Product Net New Current MRR] decimal(18,2)
	, [Subscription Product Net Growth Current MRR] decimal(18,2)
	, [Subscription Product Net Churn Current MRR] decimal(18,2)
	, [Subscription Product Net Contraction Current MRR] decimal(18,2)
)

-- Determine new vs growth vs lost vs churn
INSERT INTO #MrrData
SELECT
	s.RecordDate 
	, @AccountId
	, s.CurrencyId
	, s.PlanId
	, s.ProductID
	, s.CustomerId
	, s.SubscriptionId
	, s.SubscriptionProductId
	, s.SubscriptionStatusID
	, s.SubscriptionProductIncludedStatus
	, s.SubscriptionProductQuantity
	, s.SubscriptionProductAmount
	, s.GrossMrr
	, s.NetMrr
	, CASE WHEN s.ActivationDate = s.RecordDate
                AND s.CancellationDate != s.RecordDate
		THEN s.NetMrr ELSE 0 END as [Net New MRR]
	, CASE WHEN s.ActivationDate < s.RecordDate
				AND ISNULL(yesterday.NetMrr, s.NetMrr) < s.NetMrr
		THEN s.NetMrr - ISNULL(yesterday.NetMrr, s.NetMrr) ELSE 0 END as [Net Expansion MRR]
	, CASE WHEN s.CancellationDate = s.RecordDate
		THEN -ISNULL(yesterday.NetMrr, 0) ELSE 0 END as [Net Lost MRR]
	, CASE WHEN s.ActivationDate < s.RecordDate
				AND s.CancellationDate != s.RecordDate
				AND ISNULL(yesterday.NetMrr, s.NetMrr) > s.NetMrr
		THEN s.NetMrr - ISNULL(yesterday.NetMrr, s.NetMrr) ELSE 0 END as [Net Contraction MRR]
	, CASE WHEN s.ActivationDate = s.RecordDate
                AND s.CancellationDate != s.RecordDate
		THEN s.GrossMrr ELSE 0 END as [Gross New MRR]
	, CASE WHEN s.ActivationDate < s.RecordDate
				AND ISNULL(yesterday.GrossMrr, s.GrossMrr) < s.GrossMrr
		THEN s.GrossMrr - ISNULL(yesterday.GrossMrr, s.GrossMrr) ELSE 0 END as [Gross Expansion MRR]
	, CASE WHEN s.CancellationDate = s.RecordDate
		THEN -ISNULL(yesterday.GrossMrr, 0) ELSE 0 END as [Gross Lost MRR]
	, CASE WHEN s.ActivationDate < s.RecordDate
				AND s.CancellationDate != s.RecordDate
				AND ISNULL(yesterday.GrossMrr, s.GrossMrr) > s.GrossMrr
		THEN s.GrossMrr - ISNULL(yesterday.GrossMrr, s.GrossMrr) ELSE 0 END as [Gross Contraction MRR]
	, s.SubscriptionContractStartTimestamp
	, s.SubscriptionContractEndTimestamp
	, s.SubscriptionContractValue
	, s.SubscriptionContractDurationInMonths
	, s.SalesTrackingCode1Id
	, s.SalesTrackingCode2Id
	, s.SalesTrackingCode3Id
	, s.SalesTrackingCode4Id
	, s.SalesTrackingCode5Id
	, s.TimezoneId
	, s.CurrentGrossMrr
	, s.CurrentNetMrr
	, CASE WHEN s.ActivationDate = s.RecordDate
                AND s.CancellationDate != s.RecordDate
		THEN s.CurrentGrossMrr ELSE 0 END as [Current Gross New MRR]
	, CASE WHEN s.ActivationDate < s.RecordDate
				AND ISNULL(yesterday.CurrentGrossMrr, s.CurrentGrossMrr) < s.CurrentGrossMrr
		THEN s.CurrentGrossMrr - ISNULL(yesterday.CurrentGrossMrr, s.CurrentGrossMrr) ELSE 0 END as [Current Gross Expansion MRR]
	, CASE WHEN s.CancellationDate = s.RecordDate
		THEN -ISNULL(yesterday.CurrentGrossMrr, 0) ELSE 0 END as [Current Gross Lost MRR]
	, CASE WHEN s.ActivationDate < s.RecordDate
				AND s.CancellationDate != s.RecordDate
				AND ISNULL(yesterday.CurrentGrossMrr, s.CurrentGrossMrr) > s.CurrentGrossMrr
		THEN s.CurrentGrossMrr - ISNULL(yesterday.CurrentGrossMrr, s.CurrentGrossMrr) ELSE 0 END as [Current Gross Contraction MRR]
	, CASE WHEN s.ActivationDate = s.RecordDate
                AND s.CancellationDate != s.RecordDate
		THEN s.CurrentNetMrr ELSE 0 END as [Current Net New MRR]
	, CASE WHEN s.ActivationDate < s.RecordDate
				AND ISNULL(yesterday.CurrentNetMrr, s.CurrentNetMrr) < s.CurrentNetMrr
		THEN s.CurrentNetMrr - ISNULL(yesterday.CurrentNetMrr, s.CurrentNetMrr) ELSE 0 END as [Current Net Expansion MRR]
	, CASE WHEN s.CancellationDate = s.RecordDate
		THEN -ISNULL(yesterday.CurrentNetMrr, 0) ELSE 0 END as [Current Net Lost MRR]
	, CASE WHEN s.ActivationDate < s.RecordDate
				AND s.CancellationDate != s.RecordDate
				AND ISNULL(yesterday.CurrentNetMrr, s.CurrentNetMrr) > s.CurrentNetMrr
		THEN s.CurrentNetMrr - ISNULL(yesterday.CurrentNetMrr, s.CurrentNetMrr) ELSE 0 END as [Current Net Contraction MRR]
FROM #DailySubscriptionData s
LEFT JOIN #DailySubscriptionData yesterday ON s.SubscriptionProductId = yesterday.SubscriptionProductId
	AND DATEADD(day,-1,s.RecordDate) = yesterday.RecordDate

SELECT * FROM #MrrData
WHERE [Report Date] >= @StartDate -- exclude the extra day that was added earlier
ORDER BY [Customer ID], [Subscription ID], [Subscription Product ID], [Report Date]

DROP TABLE #SubscriptionDeltasByDay
DROP TABLE #DailySubscriptionData
DROP TABLE #MrrData

GO

