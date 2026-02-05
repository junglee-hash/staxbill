/********************************************************************
If CurrencyId is null it returns all
If @SalesTrackingCode()IdList is null it returns all that are not set
If @SalesTrackingCode()IdList = '' it returns all 
If @SalesTrackingCode()IdList = '1,2,3' it returns any of the three 

*********************************************************************/
CREATE procedure [dbo].[usp_GetCohortForFrequency]
	@AccountId bigint 
	,@PlanFrequencyUniqueId bigint = null
	, @PlanId bigint = null
	,@UtcStartDateTime datetime 
	,@UtcEndDateTime datetime 
	, @CurrencyId int 
	, @SalesTrackingCode1IdList nvarchar(2000) = null
	, @SalesTrackingCode2IdList nvarchar(2000) = null 
	, @SalesTrackingCode3IdList nvarchar(2000) = null
	, @SalesTrackingCode4IdList nvarchar(2000) = null 
	, @SalesTrackingCode5IdList nvarchar(2000) = null 
as

set transaction isolation level snapshot

if @UtcEndDateTime   is null
	set @UtcEndDateTime = getutcdate()
if  @UtcStartDateTime   is null
	set @UtcStartDateTime = dateadd(year,-1,@UtcEndDateTime)

declare @TimezoneId int

select 
	@TimezoneId = TimezoneId 
from 
	AccountPreference
where 
	Id = @Accountid 

create table #DateRange 
(
	CalendarYear int 
	,MonthOfYear int
	,FullDate datetime
	,ModifiedDate datetime
	,MonthName varchar(60)
)

insert into 
	#DateRange 
select 
	CalendarYear
	,MonthOfYear 
	,FullDate
	, dbo.fn_getUtcTime(dateadd(day,1,FullDate),@TimezoneId) as ModifiedDate
	,MonthName   
from 
	dim.Date d  
where 
	IsLastDayOfMonth = 'Y'
	and d.FullDate >= @UtcStartDateTime 
	and d.FullDate <= @UtcEndDateTime



create table  #ActiveSubscriptions 
(
	CurrentId bigint
	,CalendarYear int
	,MonthOfYear int
	,FullDate datetime
	,MonthName varchar(60)
	,Cohort datetime
)
declare @SQL nvarchar(max)
select @SQL = '
Select 
	max(ssj.Id) as CurrentId
	,CalendarYear
	,MonthOfYear 
	,FullDate
	,MonthName 
	,eomonth(dbo.fn_GetTImezoneTime(s.ActivationTimestamp,@TimezoneId )) as Cohort 
from 
	SubscriptionStatusJournal ssj
	inner join #DateRange dr 
	on ssj.CreatedTimestamp < dr.ModifiedDate
	inner join Subscription s 
	on ssj.SubscriptionId = s.Id 
	and s.ActivationTimestamp < dr.ModifiedDate
	inner join PlanFrequency pf on s.PlanFrequencyId = pf.Id 
	inner join PlanRevision pr on pf.PlanRevisionId = pr.Id 
		inner join [Plan] pl on pr.PlanId = pl.Id 
	inner join Customer c on s.customerId = c.Id
	inner join CustomerReference cr
	on c.Id = cr.Id
where
	s.ActivationTimestamp > dateadd(year,-1,eomonth(dbo.fn_getTimezoneTime(@UtcStartDateTime,@TimezoneId)))
	and c.AccountId = @AccountId
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
Group by 
	SubscriptionId
	,CalendarYear
	, MonthOfYear 
	,FullDate
	,MonthName 
	,eomonth(dbo.fn_GetTImezoneTime(s.ActivationTimestamp,@TimezoneId ))'

insert into #ActiveSubscriptions 
exec sp_executesql @SQL, N'@AccountId bigint,@PlanId bigint ,@PlanFrequencyUniqueId bigint ,@UtcStartDateTime datetime ,@TimezoneId int',@AccountId, @PlanId ,@PlanFrequencyUniqueId ,@UtcStartDateTime ,@TimezoneId 

	
Select 
	CalendarYear 
	,MonthName
	,Cohort
	,Count(Active) as CountOfTotal
	,sum(Active) as CountOfActive
	,cast(sum(Active)/cast(Count(Active) as Decimal(18,2)) * 100 as decimal(5,2)) as Percentage
from
(
Select 
	acs.CalendarYear
	, MonthName
	,acs.MonthOfYear 
	,case when ssj.statusId = 2 then 1 else 0 end as Active
	,acs.Cohort
	,s.ActivationTimestamp 
from 
	SubscriptionStatusJournal ssj
	inner join #ActiveSubscriptions acs on ssj.id = acs.CurrentId 
	inner join Subscription s on ssj.SubscriptionId = s.Id 
)Data  
group by
	CalendarYear 
	,MonthName
	,Cohort
	,MonthOfYear
Order by 
	Cohort
	,CalendarYear
	,MonthOfYear;
--option (MaxDop 1 );

drop table #DateRange
drop table #ActiveSubscriptions

GO

