CREATE procedure [dbo].[usp_PopulateFactSubscriptionProduct]
AS
Set Transaction Isolation Level Snapshot
Merge into Reporting.FactSubscriptionProduct as Target 
using(
select 
	convert(date,dbo.fn_GetTimezoneTime(GETUTCDATE(),ap.timezoneid)) as ReportDate 
	,sp.Id as SubscriptionProductId
	,a.Id as AccountId
	,s.CustomerId
	,sp.SubscriptionId as SubscriptionId
	,pr.PlanId  as PlanId
	,pp.ProductId as ProductId
	,iv.Name as IntervalName
	,pf.NumberOfIntervals as NumberOfIntervals
	,convert(date,dbo.fn_GetTimezoneTime(s.ActivationTimestamp,ap.timezoneid)) as SubscriptionActivationTimestamp 
	,convert(date,dbo.fn_GetTimezoneTime(s.CancellationTimestamp,ap.timezoneid)) as SubscriptionCancellationTimestamp 
	,sp.Quantity as ProductQuantity
	,sp.MonthlyRecurringRevenue as MRR
	,cu.IsoName as Currency
from 
	Subscription s 
	inner join PlanFrequency pf
	on s.PlanFrequencyId = pf.id 
	inner join lookup.Interval iv
	on pf.Interval = iv.id
	inner join dbo.PlanRevision pr
	on pf.PlanRevisionId = pr.id
	inner join dbo.customer c
	on s.CustomerId = c.id 
	inner join dbo.SubscriptionProduct sp
	on s.Id = sp.SubscriptionId 
	inner join dbo.PlanProduct pp
	on sp.PlanProductId = pp.id 
	inner join dbo.Product p
	on pp.ProductId = p.Id 
	inner join lookup.Currency cu
	on c.CurrencyId = cu.id
	inner join dbo.AccountPreference ap
	on c.AccountId = ap.id
	inner join dbo.account a on ap.id = a.id
where
	a.CompanyName <> 'Fusebill Integration Test'
	and ContactEmail not like '%noreply@fusebillintegrationtest.com%'	
	)
	As Source
ON Target.ReportDate = Source.ReportDate
and Target.SubscriptionProductId = Source.SubscriptionProductId
WHEN Matched
THEN Update
	set 
	Target.ProductId = Source.ProductId
	,Target.SubscriptionActivationTimestamp   = Source.SubscriptionActivationTimestamp
	,Target.SubscriptionCancellationTimestamp   = Source.SubscriptionCancellationTimestamp
	,Target.ProductQuantity  = Source.ProductQuantity
	,Target.MRR  = Source.MRR
WHEN NOT MATCHED
THEN Insert
(ReportDate, SubscriptionProductId, AccountId, CustomerId, SubscriptionId, PlanId, ProductId, IntervalName, NumberOfIntervals, SubscriptionActivationTimestamp, SubscriptionCancellationTimestamp, ProductQuantity, MRR, Currency )
values
(Source.ReportDate, Source.SubscriptionProductId, Source.AccountId, Source.CustomerId, Source.SubscriptionId, Source.PlanId, Source.ProductId, Source.IntervalName, Source.NumberOfIntervals, Source.SubscriptionActivationTimestamp, Source.SubscriptionCancellationTimestamp, Source.ProductQuantity, Source.MRR, Source.Currency )
;

GO

