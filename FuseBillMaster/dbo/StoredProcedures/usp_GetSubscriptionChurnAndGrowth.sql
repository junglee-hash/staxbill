/********************************************************************


If CurrencyId is null it returns all
If @SalesTrackingCode()IdList is null it returns all that are not set
If @SalesTrackingCode()IdList = '' it returns all 
If @SalesTrackingCode()IdList = '1,2,3' it returns any of the three 

*********************************************************************/


CREATE Procedure [dbo].[usp_GetSubscriptionChurnAndGrowth]
	@AccountId bigint 
	, @StartDate datetime 
	, @EndDate datetime 
	, @PlanFrequencyUniqueId bigint = null
	, @PlanId bigint = null
	, @CurrencyId int = null
	, @SalesTrackingCode1IdList nvarchar(2000) = null
	, @SalesTrackingCode2IdList nvarchar(2000) = null 
	, @SalesTrackingCode3IdList nvarchar(2000) = null
	, @SalesTrackingCode4IdList nvarchar(2000) = null 
	, @SalesTrackingCode5IdList nvarchar(2000) = null 
AS
	set nocount on
	set transaction isolation level snapshot
	if @StartDate is null
		set @StartDate = dateadd(month,-12,getutcdate())
	if @EndDate is null
		set @EndDate = getutcdate()

	declare
		@TimezoneId int 
	select 
		@TimezoneId = TimezoneId 
	from 
		AccountPreference 
	where 
		Id = @AccountId 

	create table #Dates 
	(
		AdjustedTime datetime
		,FullDate date
		,DisplayDate date
	)
	;With Dates as
	(
	Select 
		dbo.fn_GetUtcTime ( FullDate ,@TimezoneId) as AdjustedTime
		,FullDate
		,dateadd(day,-1,FullDate) as DisplayDate
	from 
		dim.Date dd
	where 
		dd.FullDate >= @StartDate 
		and dd.FullDate <= @EndDate 
		and DayOfMonth = 1
	)
	Insert into #Dates 
	(
		AdjustedTime 
		,FullDate 
		,DisplayDate
	)
	Select 
		AdjustedTime 
		,FullDate 
		,DisplayDate
	from 
		Dates

	create table #ClosestSubscriptionStatus 
	(
		FullDate datetime 
		,FullDateLastMonth datetime
		,DisplayDate varchar(60)
		,SubscriptionId bigint
		,ClosestSubscriptionStatusId bigint
		,Currency varchar(200)
	)

	create Index TMPIX_FullDate on #ClosestSubscriptionStatus (FullDate)
	create Index TMPIX_FullDateLastMonth on #ClosestSubscriptionStatus (FullDateLastMonth)
	declare @SQL nvarchar(max)

	select @SQL = N'
	set nocount on
	set transaction isolation level snapshot
	Select
		ds.FullDate 
		,dateadd(month,-1,FullDate) as FullDateLastMonth
		,ds.DisplayDate
		,ssj.SubscriptionId 
		,Max(ssj.Id) as ClosestSubscriptionStatusId
		,lc.IsoName as Currency
	from
		Customer c
		inner join Subscription s 
		on c.Id = s.CustomerId '
	select @SQL = @SQL +
	'
		inner join CustomerReference cr on c.Id = cr.Id
		inner join PlanFrequency pf on s.PlanFrequencyId = pf.Id 
		inner join PlanRevision pr on pf.PlanRevisionId = pr.Id 
		inner join [Plan] pl on pr.PlanId = pl.Id 
		inner join SubscriptionStatusJournal ssj on ssj.SubscriptionId = s.Id
		inner join #Dates ds on ssj.CreatedTimestamp< ds.AdjustedTime 
		inner join lookup.Currency lc on c.CurrencyId = lc.Id 
	WHERE
		 c.AccountId = @AccountId 
		 AND s.IsDeleted = 0
		 ' + case 
				when @PlanId is not null then 'and pl.Id = @PlanId'else '' end +'
		 ' + case 
				when @PlanFrequencyUniqueId is not null then 'and pf.PlanFrequencyUniqueId = @PlanFrequencyUniqueId'else '' end +'
		 ' + case 
				when @CurrencyId is not null then 'and c.CurrencyId =  ' + convert(varchar(2),@CurrencyId) else '' end +'
		 ' + case 
				when @SalesTrackingCode1IdList is null then 'and cr.SalesTrackingCode1Id is null'
				when @SalesTrackingCode1IdList = '' then ''
				else 'and cr.SalesTrackingCode1Id in (' + @SalesTrackingCode1IdList +')' end + '
		' + case 
				when @SalesTrackingCode2IdList is null then 'and cr.SalesTrackingCode2Id is null'
				when @SalesTrackingCode2IdList = '' then ''
				else 'and cr.SalesTrackingCode2Id in (' + @SalesTrackingCode2IdList +')' end + '
		' + case 
				when @SalesTrackingCode3IdList is null then 'and cr.SalesTrackingCode3Id is null'
				when @SalesTrackingCode3IdList = '' then ''
				else 'and cr.SalesTrackingCode3Id in (' + @SalesTrackingCode3IdList +')' end + '
		' + case 
				when @SalesTrackingCode4IdList is null then 'and cr.SalesTrackingCode4Id is null'
				when @SalesTrackingCode4IdList = '' then ''
				else 'and cr.SalesTrackingCode4Id in (' + @SalesTrackingCode4IdList +')' end + '
	' + case 
				when @SalesTrackingCode5IdList is null then 'and cr.SalesTrackingCode5Id is null'
				when @SalesTrackingCode5IdList = '' then ''
				else 'and cr.SalesTrackingCode5Id in (' + @SalesTrackingCode5IdList +')' end + '
	 
	group by
	ds.FullDate 
	,ssj.SubscriptionId 
	,ds.DisplayDate
	,lc.IsoName 
	Order by ds.FullDate
	option (maxdop 1);
	set nocount off
	'
	insert into #ClosestSubscriptionStatus 
	exec sp_executesql @SQL ,N'@AccountId bigint, @PlanId bigint, @PlanFrequencyUniqueId bigint, @CurrencyId int',@AccountId, @PlanId ,@PlanFrequencyUniqueId, @CurrencyId

	Select 
		DisplayDate
		,sum(ActiveAtStartOfMonth) as ActiveAtStartOfMonth
		,sum(CancelledInMonth) as CancelledInMonth
		,cast(case when sum(ActiveAtStartOfMonth) > 0 then   (sum(CancelledInMonth)/ cast(sum(ActiveAtStartOfMonth) as decimal(10,2)))*100 else 0 end as decimal(5,2)) as ChurnPercentage
		,sum(CreatedInMonth) as ActivatedInMonth
		,sum(ActiveAtStartOfMonth) - sum(CancelledInMonth) + sum(CreatedInMonth) as ActiveAtEndOfMonth
		,cast(( sum(CreatedInMonth)) / cast(case when sum(ActiveAtStartOfMonth)= 0 then null else sum(ActiveAtStartOfMonth) end as decimal(10,2))*100 as decimal(10,2)) as GrowthPercentage
		,Currency 
	from
	(
	Select 
		cse.DisplayDate
		,case when ssj.StatusId = 2 then 1 else 0 end as ActiveAtStartOfMonth
		,case when ssj.StatusId = 2 and ssje.StatusId in(3,5,6) then 1 else 0 end as CancelledInMonth
		,case when isnull(ssj.StatusId,0) != 2 and ssje.StatusId = 2 then 1 else 0 end as CreatedInMonth
		,cse.Currency
	from 
		#ClosestSubscriptionStatus css
		inner join SubscriptionStatusJournal ssj on css.ClosestSubscriptionStatusId = ssj.Id 
		right join #ClosestSubscriptionStatus cse
		on css.FullDate  = cse.FullDateLastMonth
		and css.SubscriptionId = cse.SubscriptionId 
		left join SubscriptionStatusJournal ssje on cse.ClosestSubscriptionStatusId = ssje.Id 
	)Churn
	where DisplayDate > @StartDate 
	group by 
	DisplayDate 
	,Currency 
	order by Currency,DisplayDate;
	--option (maxdop 1 );



	drop table #ClosestSubscriptionStatus
	drop table #Dates

	set nocount off

GO

