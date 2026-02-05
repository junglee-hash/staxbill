
CREATE PROCEDURE [Reporting].[Assured_SubscriptionChurn]
@AccountId BIGINT
AS
BEGIN


set nocount on
set transaction isolation level snapshot


Declare @StartDate datetime = convert(date,getutcdate())
;With ChurnAndGrowth as
(
Select
td.ReportDate
,td.SubscriptionProductId
,td.SubscriptionId
,td.PlanId
,td.ProductId  
,
isnull(ys.Mrr,0) as Yesterday
, isnull(td.Mrr,0)  Today
,isnull(td.Mrr,0) - isnull(ys.Mrr,0)  as Change
,isnull(td.SubscriptionCancellationTimestamp,'2250-01-01')  as SubscriptionCancellationTimestamp
,td.Currency
from
Reporting.FactSubscriptionProduct td
left join Reporting.FactSubscriptionProduct ys
on td.SubscriptionProductId = ys.SubscriptionProductId
and td.ReportDate = dateadd(day,1,ys.ReportDate)

WHERE
td.AccountId = @AccountId

)
Select * from
(
Select
Month
,convert(varchar(60),CountOfSubscriptions ) as CountOfSubscription
,PlanName
,ProductName
,convert(varchar(60),OpeningMrr ) as OpeningMrr
,convert(varchar(60),ChurnMrr ) as ChurnMrr
,convert(varchar(60),GrowthMrr ) as GrowthMrr
,convert(varchar(60),OpeningMrr + ChurnMrr + GrowthMrr) AS NetMrr
,convert(varchar(60),Currency) as Currency
from
(
select
FullDate
,DateName(Month,d.FullDate) +', ' + DateName(Year,d.FullDate) as Month
,count(distinct case when scm.SubscriptionCancellationTimestamp > d.FullDate then scm.SubscriptionProductId  else null end ) as CountOfSubscriptions
,pl.Name as PlanName
,pp.Name  as ProductName
,sum(case when  DatePart(day,scm.ReportDate) = 1 then scm.Yesterday else 0 end) as OpeningMrr
,sum(case when  scm.Yesterday > scm.Today then scm.Today - scm.Yesterday  else 0 end) as ChurnMrr
,sum(case when scm.Yesterday is null then 0 when scm.Yesterday < scm.Today then scm.Today - scm.Yesterday else 0 end) as GrowthMrr
,Currency
from
Dim.Date d
left join ChurnAndGrowth scm
on datepart(month,d.FullDate) = datepart(month,scm.ReportDate)
and datepart(year,d.FullDate) = datepart(year, scm.ReportDate)
left join [plan] pl on scm.PlanId = pl.Id
left join SubscriptionProduct sp
on scm.SubscriptionProductId = sp.Id
left join PlanProduct pp on sp.PlanProductId = pp.id
where
d.FullDate >=dateadd(month,-1,@StartDate)
and
d.FullDate < @StartDate
and datepart(day,d.FullDate) = 1
Group by d.FullDate,pl.Name ,pp.Name  ,Currency
)Result
Where PlanName is not null and ProductName is not null
)data2
Order by Month, Currency ,PlanName ,ProductName;
--option (maxdop 1);
set nocount off

END

GO

