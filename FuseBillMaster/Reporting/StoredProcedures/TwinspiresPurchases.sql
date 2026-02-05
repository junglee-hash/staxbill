

CREATE procedure [Reporting].[TwinspiresPurchases]
--declare
@AccountId bigint = 10136
,@Interval nvarchar(10) = 'Daily'
,@EndDate datetime = NULL
AS


set transaction isolation level snapshot
set nocount on
declare 
@StartDate datetime
,@TimezoneId int

if @EndDate IS NULL
begin
	set @EndDate = getutcdate()
end

set @EndDate = convert(date,@EndDate)

set @StartDate = dateadd(day,-1,@EndDate)

if @Interval = 'Monthly'
begin
	set @StartDate = dateadd(month,-1,@EndDate)
end


Select 
	@EndDate = dbo.fn_GetUtcTime (@EndDate, ap.TimezoneId)
	,@StartDate = dbo.fn_GetUtcTime (@StartDate, ap.TimezoneId)
	,@TimezoneId = TimezoneId
from 
	AccountPreference ap
where 
	ap.Id = @AccountId 

create table #Results
(
[CAM ID] nvarchar(4000)
,FusebillId bigint
,[Subscription Product ID]varchar(4000)
,[Purchase ID]varchar(4000)
,[Affiliate ID]varchar(4000)
,[Transaction Date]varchar(4000)
,[Transaction ID] bigint
,[Product code] varchar(4000)
,[Plan Name] varchar(4000)
,Reference nvarchar(4000)
,[Regular Price] varchar(4000)
,[Actual Price Charged] varchar(4000)
,[Reason for Price Difference] varchar(4000)
,InvoiceId bigint
)

Insert into #Results
select
	''''+c.Reference as [CAM ID]
	,c.Id as FusebillId
	,convert(varchar(60),sp.Id)  as [Subscription Product ID]
    ,NULL  as [Purchase ID]
    ,ISNULL(stc.Code,'') as [Affiliate ID]
	,convert(varchar(60),convert(smalldatetime,dbo.fn_GetTimezoneTime (t.effectiveTimestamp,@Timezoneid))) as [Transaction Date]
	,ch.Id as [Transaction ID]
	,case when sp.IsRecurring = 1 then s.PlanCode else sp.PlanProductCode end as [Product code]
	,s.PlanName
	,isnull(pi.Reference ,'') as Reference
	,convert(varchar(60),cast(ISNULL(pri.Amount, sppr.Amount) as decimal (18,2)) ) as [Regular Price]
	,convert(varchar(60),cast(t.Amount as decimal (18,2))) as [Actual Price Charged]
	,'' as [Reason for Price Difference]
	,ch.InvoiceId
from 
	customer c
	inner join [Transaction] t on t.CustomerId = c.id
	inner join charge ch on t.id = ch.id
	inner join SubscriptionProductCharge spc on ch.id = spc.Id
	inner join SubscriptionProduct sp on spc.SubscriptionProductId = sp.id

	--adding product price and removing subscription product price at twinspires request https://na37.salesforce.com/5000P00000ZapMR
	inner join Product pro on pro.Id = sp.ProductId
	left join OrderToCashCycle occ	on Pro.OrderToCashCycleId = occ.Id
	left join QuantityRange qr	on occ.id = qr.OrderToCashCycleId
	left join Price pri	on qr.id = pri.QuantityRangeId 	and c.CurrencyId = pri.CurrencyId 
	INNER JOIN SubscriptionProductPriceRange sppr ON sp.Id = sppr.SubscriptionProductId

	inner join Subscription s on sp.SubscriptionId = s.Id
	left join ChargeProductItem cspi on ch.id = cspi.ChargeId 
	inner join ProductItem pi on cspi.ProductItemId = pi.Id 	
	INNER JOIN CustomerReference cr ON c.Id = cr.Id
	LEFT JOIN SalesTrackingCode stc ON stc.Id = cr.SalesTrackingCode1Id	

where 
	c.AccountId = @AccountId
	and t.EffectiveTimestamp >=@StartDate 
	and t.EffectiveTimestamp < @EndDate 
	
UNION ALL

select
	''''+c.Reference as [CAM ID]
	,c.Id as FusebillId
	,NULL  as [Subscription Product ID]
    ,convert(varchar(60),pu.Id)  as [Purchase ID]
    ,ISNULL(stc.Code,'') as [Affiliate ID]
	,convert(varchar(60),convert(smalldatetime,dbo.fn_GetTimezoneTime (t.effectiveTimestamp,@Timezoneid))) as [Transaction Date]
	,ch.Id as [Transaction ID]
	,pro.code as [Product code]
	,'' as PlanName
	,isnull(pi.Reference ,'') as Reference
	,convert(varchar(60),cast(pri.Amount as decimal (18,2)) ) as [Regular Price]
	,convert(varchar(60),cast(t.Amount as decimal (18,2))) as [Actual Price Charged]
	,'' as [Reason for Price Difference]
	,ch.InvoiceId
from 
	customer c
	inner join [Transaction] t	on t.CustomerId = c.id
	inner join charge ch	on t.id = ch.id
	inner join PurchaseCharge pc	on ch.Id = pc.Id 
	inner join Purchase pu	on pc.PurchaseId = pu.Id
	inner join Product pro	on pu.ProductId = pro.Id 
	left join ChargeProductItem cspi	on ch.id = cspi.ChargeId 
	inner join ProductItem pi	on cspi.ProductItemId = pi.Id 
	inner join OrderToCashCycle occ	on Pro.OrderToCashCycleId = occ.Id
	inner join QuantityRange qr	on occ.id = qr.OrderToCashCycleId
	inner join Price pri	on qr.id = pri.QuantityRangeId 	and c.CurrencyId = pri.CurrencyId 
	INNER JOIN CustomerReference cr ON c.Id = cr.Id
	LEFT JOIN SalesTrackingCode stc ON stc.Id = cr.SalesTrackingCode1Id	
where 
	c.AccountId = @AccountId
	and t.EffectiveTimestamp >=@StartDate 
	and t.EffectiveTimestamp < @EndDate 

UNION ALL

select
	''''+c.Reference as [CAM ID]
	,c.Id as FusebillId
	,convert(varchar(60),sp.Id)  as [Subscription Product ID]
    ,NULL  as [Purchase ID]
    ,ISNULL(stc.Code,'') as [Affiliate ID]
	,convert(varchar(60),convert(smalldatetime,dbo.fn_GetTimezoneTime (t.effectiveTimestamp,@Timezoneid))) as [Transaction Date]
	,ch.Id as [Transaction ID]
	,case when sp.IsRecurring = 1 then s.PlanCode else sp.PlanProductCode end as [Product code]
	,s.PlanName
	,'' as Reference
	,convert(varchar(60),cast(ISNULL(pri.Amount, sppr.Amount) as decimal (18,2)) ) as [Regular Price]
	,convert(varchar(60),cast(t.Amount as decimal (18,2))) as [Actual Price Charged]
	,'' as [Reason for Price Difference]
	,ch.InvoiceId
from 
	customer c
	inner join [Transaction] t 	on t.CustomerId = c.id
	inner join charge ch	on t.id = ch.id
	inner join SubscriptionProductCharge spc	on ch.id = spc.Id
	inner join SubscriptionProduct sp	on spc.SubscriptionProductId = sp.id
	inner join Subscription s 	on sp.SubscriptionId = s.Id
	left join SubscriptionProductActivityJournalCharge spajc	on ch.id = spajc.ChargeId 
	left join ChargeProductItem cspi	on ch.id = cspi.ChargeId 

	--adding product price and removing subscription product price at twinspires request https://na37.salesforce.com/5000P00000ZapMR
	inner join Product pro on pro.Id = sp.ProductId
	left join OrderToCashCycle occ	on Pro.OrderToCashCycleId = occ.Id
	left join QuantityRange qr	on occ.id = qr.OrderToCashCycleId
	left join Price pri	on qr.id = pri.QuantityRangeId 	and c.CurrencyId = pri.CurrencyId 
	INNER JOIN SubscriptionProductPriceRange sppr ON sp.Id = sppr.SubscriptionProductId

	INNER JOIN CustomerReference cr ON c.Id = cr.Id
	LEFT JOIN SalesTrackingCode stc ON stc.Id = cr.SalesTrackingCode1Id	
where 
	c.AccountId = @AccountId
	and ch.Quantity > 0
	and t.EffectiveTimestamp >=@StartDate 
	and t.EffectiveTimestamp < @EndDate 
	and cspi.Id is null

--reverse charges
union all

select
	''''+c.Reference as [CAM ID]
	,c.Id as FusebillId
	,convert(varchar(60),sp.Id)  as [Subscription Product ID]
    ,NULL  as [Purchase ID]
    ,ISNULL(stc.Code,'') as [Affiliate ID]
	,convert(varchar(60),convert(smalldatetime,dbo.fn_GetTimezoneTime (rt.effectiveTimestamp,@Timezoneid))) as [Transaction Date]
	,rch.Id as [Transaction ID]
	,case when sp.IsRecurring = 1 then s.PlanCode else sp.PlanProductCode end as [Product code]
	,s.PlanName
	,isnull(pi.Reference ,'') as Reference
	,convert(varchar(60),cast(ISNULL(-pri.Amount, -sppr.Amount) as decimal (18,2)) ) as [Regular Price]
	,convert(varchar(60),cast(-rt.Amount as decimal (18,2))) as [Actual Price Charged]
	,'CN' as [Reason for Price Difference]
	,ch.InvoiceId
from 
	customer c
	inner join [Transaction] t	on t.CustomerId = c.id
	inner join charge ch	on t.id = ch.id
	inner join SubscriptionProductCharge spc	on ch.id = spc.Id
	inner join SubscriptionProduct sp	on spc.SubscriptionProductId = sp.id
	inner join Subscription s 	on sp.SubscriptionId = s.Id
	left join ChargeProductItem cspi	on ch.id = cspi.ChargeId 
	left join ProductItem pi	on cspi.ProductItemId = pi.Id 

	--adding product price and removing subscription product price at twinspires request https://na37.salesforce.com/5000P00000ZapMR
	inner join Product pro on pro.Id = sp.ProductId
	left join OrderToCashCycle occ	on Pro.OrderToCashCycleId = occ.Id
	left join QuantityRange qr	on occ.id = qr.OrderToCashCycleId
	left join Price pri	on qr.id = pri.QuantityRangeId 	and c.CurrencyId = pri.CurrencyId 
	INNER JOIN SubscriptionProductPriceRange sppr ON sp.Id = sppr.SubscriptionProductId

	inner join reverseCharge rch on t.Id = rch.OriginalChargeId
	inner join [Transaction] rt on rch.Id = rt.Id
	INNER JOIN CustomerReference cr ON c.Id = cr.Id
	LEFT JOIN SalesTrackingCode stc ON stc.Id = cr.SalesTrackingCode1Id	
where 
	c.AccountId = @AccountId
	and rt.EffectiveTimestamp >=@StartDate 
	and rt.EffectiveTimestamp < @EndDate 

UNION ALL

select
	''''+c.Reference as [CAM ID]
	,c.Id as FusebillId
	,NULL  as [Subscription Product ID]
    ,convert(varchar(60),pu.Id)  as [Purchase ID]
    ,ISNULL(stc.Code,'') as [Affiliate ID]
	,convert(varchar(60),convert(smalldatetime,dbo.fn_GetTimezoneTime (rt.effectiveTimestamp,@Timezoneid))) as [Transaction Date]
	,rch.Id as [Transaction ID]
	,pro.code as [Product code]
	,'' as PlanName
	,isnull(pi.Reference ,'') as Reference
	,convert(varchar(60),cast(-pri.Amount as decimal (18,2)) ) as [Regular Price]
	,convert(varchar(60),cast(-rt.Amount as decimal (18,2))) as [Actual Price Charged]
	,'CN' as [Reason for Price Difference]
	,ch.InvoiceId
from 
	customer c
	inner join [Transaction] t	on t.CustomerId = c.id
	inner join charge ch	on t.id = ch.id
	inner join PurchaseCharge pc	on ch.Id = pc.Id 
	inner join Purchase pu	on pc.PurchaseId = pu.Id
	inner join Product pro	on pu.ProductId = pro.Id 
	left join ChargeProductItem cspi	on ch.id = cspi.ChargeId 
	inner join ProductItem pi	on cspi.ProductItemId = pi.Id 
	inner join OrderToCashCycle occ	on Pro.OrderToCashCycleId = occ.Id
	inner join QuantityRange qr	on occ.id = qr.OrderToCashCycleId
	inner join Price pri	on qr.id = pri.QuantityRangeId 	and c.CurrencyId = pri.CurrencyId 
	inner join reverseCharge rch on t.Id = rch.OriginalChargeId
	inner join [Transaction] rt on rch.Id = rt.Id
	INNER JOIN CustomerReference cr ON c.Id = cr.Id
	LEFT JOIN SalesTrackingCode stc ON stc.Id = cr.SalesTrackingCode1Id	
where 
	c.AccountId = @AccountId
	and rt.EffectiveTimestamp >=@StartDate 
	and rt.EffectiveTimestamp < @EndDate 

declare @PaymentMethods table

(
Id bigint
,PaymentMethods varchar(4000)
)

Insert into @PaymentMethods
Select ch.InvoiceId, 
    coalesce(max(pm.AccountType) + ' ', '') as PaymentMethods
    from PaymentNote  pn
	inner join Payment p	on pn.PaymentId = p.Id 
	inner join PaymentActivityJournal paj	on p.PaymentActivityJournalId = paj.Id
	inner join PaymentMethod pm	on paj.PaymentMethodId = pm.id --and pm.isdefault = 1 and pm.paymentmethodstatusId = 1
	inner join Charge ch on pn.InvoiceId = ch.InvoiceId 	 
	inner join [Transaction] T	on ch.id = t.id 
	inner join Customer c	on t.CustomerId = c.Id 
	inner join #Results r	on c.Id = r.FusebillId
where 
	c.AccountId = @AccountId
	--No date filtering as Twinspires always cares about what the invoice was paid by
group by ch.InvoiceId,pm.AccountType

create table #Credits
(
InvoiceId bigint
,Credits varchar(4000)
)
insert into #Credits
select 
	ch.InvoiceId
	, COALESCE('Credited'+ ' ', '') as Credits
From 
	Charge ch
	inner join CreditAllocation  rn on ch.InvoiceId = rn.InvoiceId 
	inner join [Transaction] T	on ch.id = t.id 
	inner join Customer c	on t.CustomerId = c.Id 
	inner join #Results r	on c.Id = r.FusebillId
where 
	c.AccountId = @AccountId 
	and t.EffectiveTimestamp >=@StartDate 
	and t.EffectiveTimestamp < @EndDate 
group by ch.InvoiceId

create table #Refunds
(
Id bigint
,Refunds varchar(4000)
)


insert into #Refunds
select 
	ch.InvoiceId
	, COALESCE('Refunded'+ ' ', '') as Refunds
From 
	Charge ch
	inner join RefundNote rn on ch.InvoiceId = rn.InvoiceId 
	inner join [Transaction] T	on ch.id = t.id 
	inner join Customer c	on t.CustomerId = c.Id 
	inner join #Results r	on c.Id = r.FusebillId
where 
	c.AccountId = @AccountId 
	and t.EffectiveTimestamp >=@StartDate 
	and t.EffectiveTimestamp < @EndDate 
group by ch.InvoiceId

declare @CurrentCustomerBalance table
(
Id bigint
,[Current Account Balance] varchar(60)
)

declare @DistinctCustomers table
(
CustomerId bigint
)
insert into @DistinctCustomers
(CustomerId
)
Select FusebillId from #Results r
group by FusebillId


insert into @CurrentCustomerBalance
select
t.CustomerId as Id
,convert(varchar(60), Sum(clj.ArDebit - clj.ArCredit )) as  [Current Customer Balance]
from 
	vw_CustomerLedgerJournal clj
	inner join [Transaction] t 
	on clj.TransactionId = t.id
	inner join @DistinctCustomers r
	on t.CustomerId = r.CustomerId
where t.effectivetimestamp < @EndDate
Group by t.CustomerId

declare @CustomerGroups table
(
FusebillId bigint,
CustomerGroup nvarchar(255) null
)

INSERT INTO @CustomerGroups
SELECT 
	c.Id as FusebillId,
	'"' + ISNULL(stuff((
		SELECT ',' + s.PlanCode FROM Subscription s
		WHERE s.CustomerId = c.Id
		AND s.PlanCode in ('vip','elite','csr','employee')
		AND s.StatusId = 2
		FOR XML PATH('')
	),1,1,''), '') + '"' as CustomerGroup
FROM Customer c
INNER JOIN @DistinctCustomers dc on dc.CustomerId = c.Id
WHERE c.AccountId = @AccountId

select
	[CAM ID] 	
	,[Subscription Product ID]
	,[Purchase ID]
	,[Affiliate ID]
	,[Transaction Date]
	,convert(varchar(60),[Transaction ID] ) as [Transaction ID]
	,[Product code]
	,[Plan Name] 
	,Reference 
	,[Regular Price] 
	,[Actual Price Charged] 
	,[Reason for Price Difference] 
	,case when len(isnull(pms.PaymentMethods,'') + isnull(cs.Credits,'') + isnull(rs.Refunds,'')) > 1
	then left(	isnull(pms.PaymentMethods,'') + isnull(cs.Credits,'') + isnull(rs.Refunds,''),len(isnull(pms.PaymentMethods,'') + isnull(cs.Credits,'') + isnull(rs.Refunds,'')))
	else '' end as [Payment Method]
	,ccb.[Current Account Balance] as [Current Account Balance]
	,cg.CustomerGroup as [customer_group]
	,r.FusebillId
from #Results r
	left join @PaymentMethods pms	on r.InvoiceId = pms.Id 
	left join #Credits cs	on r.InvoiceId= cs.InvoiceId 
	left join #Refunds rs	on r.InvoiceId = rs.Id 
	inner join @CurrentCustomerBalance ccb	on r.FusebillId = ccb.Id
	inner join @CustomerGroups cg on cg.FusebillId = r.FusebillId
where	
	[Product code] NOT LIKE '%plan%'
	OR CONVERT(decimal,[Current Account Balance]) <= 0


drop table #Results
drop table #Credits
drop table #Refunds
set nocount off

GO

