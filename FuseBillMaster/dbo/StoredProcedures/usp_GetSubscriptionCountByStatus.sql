CREATE procedure [dbo].[usp_GetSubscriptionCountByStatus]
	@AccountId bigint = null
	,@PlanId bigint = null
	,@PlanFrequencyUniqueId bigint = null
	,@StartDate datetime = null
	,@EndDate datetime = null
	, @SalesTrackingCode1IdList nvarchar(2000) = null
	, @SalesTrackingCode2IdList nvarchar(2000) = null 
	, @SalesTrackingCode3IdList nvarchar(2000) = null
	, @SalesTrackingCode4IdList nvarchar(2000) = null 
	, @SalesTrackingCode5IdList nvarchar(2000) = null
	, @Currency bigint = null
as

declare @SQL nvarchar(max)

if @EndDate IS NULL
	SET @EndDate = GETUTCDATE()

select @SQL = N'
set transaction isolation level snapshot

declare @CurrentStatusJournal table
(
SubscriptionId bigint
,CurrentSequenceNumber int
)

insert into @CurrentStatusJournal
(
SubscriptionId
,CurrentSequenceNumber
)
Select
SubscriptionId
,Max(ssj.SequenceNumber) as CurrentSequenceNumber
from SubscriptionStatusJournal ssj
inner join Subscription s
on ssj.SubscriptionId = s.Id
inner join Customer c on s.CustomerId = c.Id
where c.AccountId =@AccountId
AND ssj.CreatedTimestamp < @EndDate
AND s.IsDeleted = 0
group by 
SubscriptionId


select pl.Id, pl.AccountId, pl.Name, pl.Code ,ss.Name as [Status], ss.SortOrder, 
Count(distinct sub.Id) as [Count], SUM(Count(distinct sub.Id)) OVER (PARTITION BY pl.Id) as Total
from [plan] pl cross apply [Lookup].SubscriptionStatus ss
inner join PlanRevision pr ON pl.Id = pr.PlanId
inner join PlanFrequency pf ON pr.Id = pf.PlanRevisionId
left join (
		select 
			s.Id
			, ssj.StatusId
			, s.PlanId
			, s.PlanFrequencyUniqueId 
		from
			dbo.Subscription s  
			inner join Customer c on s.customerId = c.Id
			inner join CustomerReference cr on c.Id = cr.Id
			inner join @CurrentStatusJournal csj
			on s.Id = csj.SubscriptionId
			inner join SubscriptionStatusJournal ssj
			on s.Id = ssj.SubscriptionId and csj.CurrentSequenceNumber = ssj.SequenceNumber
		where 
			c.AccountId = @AccountId 
			AND s.IsDeleted = 0
			AND c.CurrencyId = ISNULL(@Currency, c.CurrencyId) 
			AND s.PlanId = ISNULL(@PlanId, s.PlanId) 
			AND s.PlanFrequencyUniqueId = ISNULL(@PlanFrequencyUniqueId,s.PlanFrequencyUniqueId
			)' +
CASE WHEN @StartDate IS NOT NULL THEN ' AND isnull(s.CreatedTimestamp, @StartDate) >= @StartDate' ELSE '' END +
CASE WHEN @EndDate IS NOT NULL THEN ' AND isnull(s.CreatedTimestamp, @EndDate) <= @EndDate' ELSE '' END +
case 
			when @SalesTrackingCode1IdList is null then ' and cr.SalesTrackingCode1Id is null'
			when @SalesTrackingCode1IdList = '' then ''
			else ' and cr.SalesTrackingCode1Id in (' + @SalesTrackingCode1IdList +')' end + '
	' + case 

			when @SalesTrackingCode2IdList is null then ' and cr.SalesTrackingCode2Id is null'
			when @SalesTrackingCode2IdList = '' then ''
			else ' and cr.SalesTrackingCode2Id in (' + @SalesTrackingCode2IdList +')' end + '
	' + case 
			when @SalesTrackingCode3IdList is null then ' and cr.SalesTrackingCode3Id is null'
			when @SalesTrackingCode3IdList = '' then ''
			else ' and cr.SalesTrackingCode3Id in (' + @SalesTrackingCode3IdList +')' end + '
	' + case 
			when @SalesTrackingCode4IdList is null then ' and cr.SalesTrackingCode4Id is null'
			when @SalesTrackingCode4IdList = '' then ''
			else ' and cr.SalesTrackingCode4Id in (' + @SalesTrackingCode4IdList +')' end + '
' + case 
			when @SalesTrackingCode5IdList is null then ' and cr.SalesTrackingCode5Id is null'
			when @SalesTrackingCode5IdList = '' then ''
			else ' and cr.SalesTrackingCode5Id in (' + @SalesTrackingCode5IdList +')' end + ') as sub on sub.PlanId = pl.Id AND sub.PlanFrequencyUniqueId = ISNULL(@PlanFrequencyUniqueId,sub.PlanFrequencyUniqueId) and sub.StatusId = ss.Id
			where pl.AccountId = @AccountId' + 
			CASE WHEN @PlanId IS NOT NULL THEN ' AND pl.Id = @PlanId' ELSE '' END +
		CASE WHEN @PlanFrequencyUniqueId IS NOT NULL THEN ' AND pf.PlanFrequencyUniqueId = @PlanFrequencyUniqueId' ELSE '' END +
			' group by pl.Id, pl.AccountId, pl.Name, pl.Code,ss.Name,ss.SortOrder order by total desc, pl.Id, ss.SortOrder'

exec sp_executesql @SQL ,N'@AccountId bigint, @PlanId bigint, @PlanFrequencyUniqueId bigint, @StartDate datetime, @EndDate datetime, @Currency bigint',@AccountId, @PlanId, @PlanFrequencyUniqueId, @StartDate, @EndDate, @Currency

GO

