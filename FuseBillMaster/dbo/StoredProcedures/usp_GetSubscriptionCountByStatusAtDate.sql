CREATE procedure [dbo].[usp_GetSubscriptionCountByStatusAtDate]
	@AccountId bigint,
	@EndDate datetime,
	@CurrencyId int = null,
	@MonthsBack nvarchar(max) = null,
	@SalesTrackingCodeType int = null,
	@SalesTrackingCodeId bigint = null
as

IF (@MonthsBack is null)
	BEGIN
		SET @MonthsBack = '0'
	END

DECLARE @MonthsBackTable TABLE
(
Id bigint
,MonthsBack nvarchar (max)
)

INSERT INTO @MonthsBackTable (Id, MonthsBack )
SELECT * FROM dbo.Split(@MonthsBack, '|')

create table #Dates ( CountsDate datetime )

INSERT INTO #Dates (CountsDate)
SELECT
	dateadd(month,-1*cast(MonthsBack as int), @EndDate)
FROM @MonthsBackTable

declare @SQL nvarchar(max)

create table #CurrentStatusJournal
(
SubscriptionId bigint
,CurrentSequenceNumber int
,CountsDate datetime
)

insert into #CurrentStatusJournal
(
SubscriptionId
,CurrentSequenceNumber
,CountsDate
)
Select
SubscriptionId
,Max(ssj.SequenceNumber) as CurrentSequenceNumber
,ds.CountsDate
from SubscriptionStatusJournal ssj (NOLOCK)
inner join Subscription s (NOLOCK) on ssj.SubscriptionId = s.Id
inner join Customer c (NOLOCK) on s.CustomerId = c.Id 
inner join #Dates ds on ssj.CreatedTimestamp < ds.CountsDate 
where c.AccountId =@AccountId
AND s.IsDeleted = 0
and ssj.CreatedTimestamp < @EndDate
and c.CurrencyId = isnull(@CurrencyId, c.CurrencyId)
group by 
SubscriptionId, ds.CountsDate

select @SQL = N'
select
	ds.CountsDate,
	cs.Id as StatusId,
	isnull(ExistingCounts.Count,0) as Count
from #Dates ds
inner join Lookup.SubscriptionStatus cs on 1 = 1
left join
	(select csj.CountsDate, ssj.StatusId, count(ssj.StatusId) as Count
	from #CurrentStatusJournal csj
	inner join SubscriptionStatusJournal ssj (NOLOCK) ON ssj.SubscriptionId = csj.SubscriptionId AND csj.CurrentSequenceNumber = ssj.SequenceNumber' +
	CASE WHEN @SalesTrackingCodeType is not null THEN
		' inner join Subscription s (NOLOCK) on s.Id = ssj.SubscriptionId and s.IsDeleted = 0
		inner join CustomerReference cr (NOLOCK) ON cr.Id = s.CustomerId' ELSE '' END +
	CASE WHEN @SalesTrackingCodeType = 1 THEN
		' AND cr.SalesTrackingCode1Id = @SalesTrackingCodeId' ELSE '' END +
	CASE WHEN @SalesTrackingCodeType = 2 THEN
		' AND cr.SalesTrackingCode2Id = @SalesTrackingCodeId' ELSE '' END +
	CASE WHEN @SalesTrackingCodeType = 3 THEN
		' AND cr.SalesTrackingCode3Id = @SalesTrackingCodeId' ELSE '' END +
	CASE WHEN @SalesTrackingCodeType = 4 THEN
		' AND cr.SalesTrackingCode4Id = @SalesTrackingCodeId' ELSE '' END +
	CASE WHEN @SalesTrackingCodeType = 5 THEN
		' AND cr.SalesTrackingCode5Id = @SalesTrackingCodeId' ELSE '' END +

	' group by csj.CountsDate, ssj.StatusId) as ExistingCounts
	on ds.CountsDate = ExistingCounts.CountsDate and cs.Id = ExistingCounts.StatusId' +
' drop table #Dates
drop table #CurrentStatusJournal
'

exec sp_executesql @SQL, N'@SalesTrackingCodeId bigint', @SalesTrackingCodeId

GO

