
CREATE PROCEDURE [Reporting].[DentalSolutions_Commissions]
	@AccountId BIGINT 
	,@StartDate DATETIME
	,@EndDate DATETIME 
	
AS
BEGIN

set nocount on
set transaction isolation level snapshot

Select 
	@EndDate = dbo.fn_GetUtcTime (@EndDate, ap.TimezoneId)
	,@StartDate = dbo.fn_GetUtcTime (@StartDate, ap.TimezoneId)
from 
	AccountPreference ap
where 
	ap.Id = @AccountId 

declare @PlanProductListPivot nvarchar(max)
declare @PlanProductListSelect nvarchar(max)

SELECT @PlanProductListPivot =  COALESCE( @PlanProductListPivot + ', ', '') +'['+pl.Code +'-'+ p.Name + ']'
FROM PlanProduct pp inner join Product p on pp.ProductId = p.Id
inner join PlanRevision pr on pp.PlanRevisionId = pr.Id 
inner join [Plan] pl on pr.PlanId = pl.id 
where p.AccountId = @Accountid 
group by p.Name,pl.Code
order by pl.Code,p.Name

SELECT @PlanProductListPivot =  COALESCE( @PlanProductListPivot + ', ', '') +'['+ p.Name + ']'
FROM Product p
where p.AccountId = @Accountid 
	and p.AvailableForPurchase = 1
group by p.Name,p.Code
order by p.Code,p.Name

SELECT @PlanProductListSelect =  COALESCE( @PlanProductListSelect + ', ', '') + ''''+pl.Code +'-'+p.Name+''''+ ' as ['+pl.Code +'-'+ p.Name + ']'
FROM PlanProduct pp inner join Product p on pp.ProductId = p.Id
inner join PlanRevision pr on pp.PlanRevisionId = pr.Id 
inner join [Plan] pl on pr.PlanId = pl.id 
where p.AccountId = @Accountid 
group by p.Name,pl.Code
order by pl.Code,p.Name

SELECT @PlanProductListSelect =  COALESCE( @PlanProductListSelect + ', ', '') + ''''+p.Name+''''+ ' as ['+ p.Name + ']'
FROM Product p
where p.AccountId = @Accountid 
	and p.AvailableForPurchase = 1
group by p.Name,p.Code
order by p.Code,p.Name

declare @PlanProductListNullable nvarchar(max)

SELECT @PlanProductListNullable =  COALESCE( @PlanProductListNullable + ', ', '') +'Convert(varchar(1000),isnull(['+pl.Code +'-'+p.Name+'],0))'+ ' as ['+pl.Code +'-'+ p.Name + ']'
FROM PlanProduct pp inner join Product p on pp.ProductId = p.Id
inner join PlanRevision pr on pp.PlanRevisionId = pr.Id 
inner join [Plan] pl on pr.PlanId = pl.id 
where p.AccountId = @Accountid 
group by p.Name,pl.Code
order by pl.Code,p.Name

SELECT @PlanProductListNullable =  COALESCE( @PlanProductListNullable + ', ', '') +'Convert(varchar(1000),isnull(['+p.Name+'],0))'+ ' as ['+ p.Name + ']'
FROM Product p
where p.AccountId = @Accountid 
	and p.AvailableForPurchase = 1
group by p.Name,p.Code
order by p.Code,p.Name


declare @SQL nvarchar(max)

set @SQL = '

set nocount on
set transaction isolation level snapshot

declare
	 @Accountid bigint = ' + convert(varchar(60),@AccountId) +'
	,@StartDate datetime = ''' + convert(varchar(60),@StartDate ) +'''
	,@EndDate Datetime = ''' + convert(varchar(60),@EndDate) +'''

; with FirstInvoiceCluster as
(
Select 
	Min(psj.Id) as PSJId
	, ij.InvoiceId
	,i.AccountId 
	,min(psj.CreatedTimestamp ) as CreatedTimestamp
	,i.InvoiceNumber
	,i.PostedTimestamp as InvoicePostedDate
from 
	InvoiceJournal ij
	inner join PaymentSchedule ps 
	on ij.InvoiceId = ps.InvoiceId 
	inner join PaymentScheduleJournal psj 
	on ps.id = psj.PaymentScheduleId
	inner join Invoice i on ij.InvoiceId = i.Id 
where 
	psj.StatusId in(4,5,7)   --paid, writtenoff, void
	and i.AccountId = @AccountId
	
group by 
	ij.InvoiceId
	, i.AccountId 
	,i.InvoiceNumber
	,i.PostedTimestamp
)
,MaxJournalEntry as
(
Select Max(Id) as MaxJournalId
,ij.InvoiceId
from InvoiceJournal ij
inner join FirstInvoiceCluster fic
on ij.InvoiceId = fic.InvoiceId
where ij.CreatedTimestamp < @EndDate
Group by ij.InvoiceId
)
,ReportRange as
(
Select
	fic.InvoiceId 
	,SumOfPayments
	,SumOfTaxes
	,SumOfRefunds
	,SumOfCreditNotes
	,SumOfDiscounts
	,SumOfCharges
	,InvoiceNumber
	,convert(date,dbo.fn_getTimezoneTime(InvoicePostedDate,ap.TimezoneId )) as InvoicePostedDate
	,convert(date,dbo.fn_getTimezoneTime(fic.CreatedTimestamp,ap.TimezoneId )) as PaIdDate
	From PaymentScheduleJournal psj
	inner join FirstInvoiceCluster fic
	on psj.Id = fic.psjId
	inner join AccountPreference ap
	on fic.AccountId = ap.Id 
	inner join MaxJournalEntry mje
	on fic.InvoiceId = mje.InvoiceId
	inner join InvoiceJournal Ij
	on mje.MaxJournalId = Ij.Id
where
	fic.AccountId  = @Accountid 
	and psj.CreatedTimestamp  >=@StartDate 
	and psj.CreatedTimestamp  < @EndDate 
), AdjustedCharge as
(
Select
 Sum(Amount) as Amount,
ChargeId
from
(
Select 
	t.Amount* ltt.ARBalanceMultiplier as Amount
,t.Id as ChargeId
From 
[Transaction] t
inner join lookup.TransactionType ltt on t.TransactionTypeId = ltt.Id 
inner join Charge ch
on t.id = ch.Id
where
	t.AccountId  = @Accountid 
	and t.EffectiveTimestamp  >=@StartDate 
	and t.EffectiveTimestamp  < @EndDate 
)data
group by ChargeId
),LatestInvoiceJournal as
(
Select InvoiceId, Max(Id) as Id
from InvoiceJournal ij
where ij.CreatedTimestamp < @EndDate
group by InvoiceId
)
Select 
SalesTrackingCode
	,isnull(SalesName,'''') as SalesName
	,isnull(Independent,'''') as Independent
	,isnull([Master Agent],'''') as [Master Agent]
	,CloserName
	,[Practice Management Software]
	,[Commission Type]
	,isnull(CompanyName,'''') as CompanyName
	,CustomerName
	,BillingState
	,convert(varchar(60),SubscriptionStartDate) as SubscriptionStartDate
	,convert(varchar(60),InvoiceNumber) as InvoiceNumber
	,convert(varchar(60),InvoicePostedDate) as InvoicePostedDate
	,convert(varchar(60),PaidDate) as PaidDate
	,
'+@PlanProductListNullable+'
,SumOfCharges
,convert(varchar(60),SumOfTaxes) as SumOfTaxes
,SumOfRefunds
,SumOfCreditNotes
,SumOfDiscounts
,SumOfPayments	
from
(
select 
	coalesce(stc1.Code,stc2.Code,stc3.Code,'''')  as SalesTrackingCode
	,replace(left(stc1.Name,charindex(''|'',stc1.Name)),''|'','''') as SalesName
	,replace(left(stc2.Name,charindex(''|'',stc2.Name)),''|'','''') as Independent
	,replace(left(stc3.Name,charindex(''|'',stc3.Name)),''|'','''') as [Master Agent]
	,isnull(stc4.Name,'''') as CloserName
	,isnull(stc5.Name,'''') as [Practice Management Software]
	,isnull(cr.Reference2,'''') as [Commission Type]
	,reverse(replace(left(reverse(coalesce(stc1.Name,stc2.Name,stc3.Name)),charindex(''|'',reverse(coalesce(stc1.Name,stc2.Name,stc3.Name)))),''|'','''')) as CompanyName
	,isnull(c.CompanyName,'''') as CustomerName
	,isnull(ls.Name,'''') as BillingState
	,convert(date,dbo.fn_getTimezoneTime(s.ActivationTimestamp,ap.TimezoneId)) as SubscriptionStartDate
	,InvoiceNumber
	,InvoicePostedDate
	,rr.PaidDate
	,ac.Amount
	,pl.Code + ''-'' + p.Name as Name
	,convert(varchar(60),SumOfTaxes) as SumOfTaxes
	,convert(varchar(60),SumOfPayments) as SumOfPayments
	,convert(varchar(60),SumOfRefunds) as SumOfRefunds
	,convert(varchar(60),SumOfCreditNotes) as SumOfCreditNotes
	,convert(varchar(60),SumOfDiscounts) as SumOfDiscounts
	,convert(varchar(60),SumOfCharges) as SumOfCharges
from 
	Charge ch 
	inner join ReportRange rr 
	on ch.InvoiceId = rr.InvoiceId 
	
	inner join AdjustedCharge ac
	on ch.Id = ac.ChargeId 
	inner join SubscriptionProductCharge spc 
	on ch.Id = spc.Id
	inner join SubscriptionProduct sp
	on spc.SubscriptionProductId = sp.Id
	inner join Subscription s 
	on sp.subscriptionId = s.Id
	--and s.StatusId in(2,4)   
	inner join Product p 
	on sp.ProductId = p.Id 
	inner join [Plan] pl on s.PlanId = pl.Id
	inner join Customer c on s.CustomerId = c.Id
	inner join CustomerReference cr on c.id = cr.Id
	inner join AccountPreference ap
	on c.AccountId = ap.Id
	left join SalesTrackingCode stc1 on cr.SalesTrackingCode1Id = stc1.Id
	left join SalesTrackingCode stc4 on cr.SalesTrackingCode4Id = stc4.Id
	left join SalesTrackingCode stc2 on cr.SalesTrackingCode2Id = stc2.Id
	left join SalesTrackingCode stc3 on cr.SalesTrackingCode3Id = stc3.Id
	left join SalesTrackingCode stc5 on cr.SalesTrackingCode5Id = stc5.Id
	left join Address a on c.Id = a.CustomerAddressPreferenceId and a.AddressTypeId = 1
	left join Lookup.State ls on a.CountryId = ls.CountryId and a.StateId = ls.Id
'
set @SQL = @SQL + '
union all

select 
	coalesce(stc1.Code,stc2.Code,stc3.Code,'''')  as SalesTrackingCode
	,replace(left(stc1.Name,charindex(''|'',stc1.Name)),''|'','''') as SalesName
	,replace(left(stc2.Name,charindex(''|'',stc2.Name)),''|'','''') as Independent
	,replace(left(stc3.Name,charindex(''|'',stc3.Name)),''|'','''') as [Master Agent]
	,isnull(stc4.Name,'''') as CloserName
	,isnull(stc5.Name,'''') as [Practice Management Software]
	,isnull(cr.Reference2,'''') as [Commission Type]
	,reverse(replace(left(reverse(coalesce(stc1.Name,stc2.Name,stc3.Name)),charindex(''|'',reverse(coalesce(stc1.Name,stc2.Name,stc3.Name)))),''|'','''')) as CompanyName
	,isnull(c.CompanyName,'''') as CustomerName
	,isnull(ls.Name,'''') as BillingState
	,convert(date,dbo.fn_getTimezoneTime(s.ActivationTimestamp,ap.TimezoneId)) as SubscriptionStartDate
	,InvoiceNumber
	,InvoicePostedDate
	,convert(date,dbo.fn_getTimezoneTime(rr.CreatedTimestamp,ap.TimezoneId )) as PaidDate
	,-t.Amount
	,pl.Code + ''-'' + p.Name as Name
	,convert(varchar(60),SumOfTaxes) as SumOfTaxes
	,convert(varchar(60),SumOfPayments) as SumOfPayments
	,convert(varchar(60),SumOfRefunds) as SumOfRefunds
	,convert(varchar(60),SumOfCreditNotes) as SumOfCreditNotes
	,convert(varchar(60),SumOfDiscounts) as SumOfDiscounts
	,convert(varchar(60),SumOfCharges) as SumOfCharges
from 
	ReverseCharge rc inner join 
	Charge ch on rc.OriginalChargeId = ch.Id
	inner join FirstInvoiceCluster rr 
	on ch.InvoiceId = rr.InvoiceId 
	inner join LatestInvoiceJournal lij on rr.InvoiceId = lij.InvoiceId
	inner join InvoiceJournal ij on lij.Id = ij.Id
	inner join [Transaction] t 
	on rc.Id = t.Id
	inner join SubscriptionProductCharge spc 
	on ch.Id = spc.Id
	inner join SubscriptionProduct sp
	on spc.SubscriptionProductId = sp.Id
	inner join Subscription s 
	on sp.subscriptionId = s.Id
	--and s.StatusId in(2,4)
	inner join Product p 
	on sp.ProductId = p.Id 
	inner join [Plan] pl on s.PlanId = pl.Id
	inner join Customer c on s.CustomerId = c.Id
	inner join CustomerReference cr on c.id = cr.Id
	inner join AccountPreference ap
	on c.AccountId = ap.Id
	left join SalesTrackingCode stc1 on cr.SalesTrackingCode1Id = stc1.Id
	left join SalesTrackingCode stc4 on cr.SalesTrackingCode4Id = stc4.Id
	left join SalesTrackingCode stc2 on cr.SalesTrackingCode2Id = stc2.Id
	left join SalesTrackingCode stc3 on cr.SalesTrackingCode3Id = stc3.Id
	left join SalesTrackingCode stc5 on cr.SalesTrackingCode5Id = stc5.Id
	left join Address a on c.Id = a.CustomerAddressPreferenceId and a.AddressTypeId = 1
	left join Lookup.State ls on a.CountryId = ls.CountryId and a.StateId = ls.Id
where t.CreatedTimestamp  >=@StartDate 
	and t.CreatedTimestamp  < @EndDate 
	--check to see that the subscription is still active
	'

SET @SQL = @SQL + '
UNION ALL

select 
	coalesce(stc1.Code,stc2.Code,stc3.Code,'''')  as SalesTrackingCode
	,replace(left(stc1.Name,charindex(''|'',stc1.Name)),''|'','''') as SalesName
	,replace(left(stc2.Name,charindex(''|'',stc2.Name)),''|'','''') as Independent
	,replace(left(stc3.Name,charindex(''|'',stc3.Name)),''|'','''') as [Master Agent]
	,isnull(stc4.Name,'''') as CloserName
	,isnull(stc5.Name,'''') as [Practice Management Software]
	,isnull(cr.Reference2,'''') as [Commission Type]
	,reverse(replace(left(reverse(coalesce(stc1.Name,stc2.Name,stc3.Name)),charindex(''|'',reverse(coalesce(stc1.Name,stc2.Name,stc3.Name)))),''|'','''')) as CompanyName
	,isnull(c.CompanyName,'''') as CustomerName
	,isnull(ls.Name,'''') as BillingState
	,convert(date,dbo.fn_getTimezoneTime(pu.PurchaseTimestamp,ap.TimezoneId)) as SubscriptionStartDate
	,InvoiceNumber
	,InvoicePostedDate
	,rr.PaidDate
	,ac.Amount
	,p.Name as Name
	,convert(varchar(60),SumOfTaxes) as SumOfTaxes
	,convert(varchar(60),SumOfPayments) as SumOfPayments
	,convert(varchar(60),SumOfRefunds) as SumOfRefunds
	,convert(varchar(60),SumOfCreditNotes) as SumOfCreditNotes
	,convert(varchar(60),SumOfDiscounts) as SumOfDiscounts
	,convert(varchar(60),SumOfCharges) as SumOfCharges
from 
	Charge ch 
	inner join ReportRange rr 
	on ch.InvoiceId = rr.InvoiceId 
	
	inner join AdjustedCharge ac
	on ch.Id = ac.ChargeId 
	inner join PurchaseCharge pc 
	on ch.Id = pc.Id
	inner join Purchase pu
	on pc.PurchaseId = pu.Id
	inner join Product p 
	on pu.ProductId = p.Id 
	inner join Customer c on pu.CustomerId = c.Id
	inner join CustomerReference cr on c.id = cr.Id
	inner join AccountPreference ap
	on c.AccountId = ap.Id
	left join SalesTrackingCode stc1 on cr.SalesTrackingCode1Id = stc1.Id
	left join SalesTrackingCode stc4 on cr.SalesTrackingCode4Id = stc4.Id
	left join SalesTrackingCode stc2 on cr.SalesTrackingCode2Id = stc2.Id
	left join SalesTrackingCode stc3 on cr.SalesTrackingCode3Id = stc3.Id
	left join SalesTrackingCode stc5 on cr.SalesTrackingCode5Id = stc5.Id
	left join Address a on c.Id = a.CustomerAddressPreferenceId and a.AddressTypeId = 1
	left join Lookup.State ls on a.CountryId = ls.CountryId and a.StateId = ls.Id
'

set @SQL = @SQL + '
union all

select 
	coalesce(stc1.Code,stc2.Code,stc3.Code,'''')  as SalesTrackingCode
	,replace(left(stc1.Name,charindex(''|'',stc1.Name)),''|'','''') as SalesName
	,replace(left(stc2.Name,charindex(''|'',stc2.Name)),''|'','''') as Independent
	,replace(left(stc3.Name,charindex(''|'',stc3.Name)),''|'','''') as [Master Agent]
	,isnull(stc4.Name,'''') as CloserName
	,isnull(stc5.Name,'''') as [Practice Management Software]
	,isnull(cr.Reference2,'''') as [Commission Type]
	,reverse(replace(left(reverse(coalesce(stc1.Name,stc2.Name,stc3.Name)),charindex(''|'',reverse(coalesce(stc1.Name,stc2.Name,stc3.Name)))),''|'','''')) as CompanyName
	,isnull(c.CompanyName,'''') as CustomerName
	,isnull(ls.Name,'''') as BillingState
	,convert(date,dbo.fn_getTimezoneTime(pu.PurchaseTimestamp,ap.TimezoneId)) as SubscriptionStartDate
	,InvoiceNumber
	,InvoicePostedDate
	,convert(date,dbo.fn_getTimezoneTime(rr.CreatedTimestamp,ap.TimezoneId )) as PaidDate
	,-t.Amount
	,p.Name as Name
	,convert(varchar(60),SumOfTaxes) as SumOfTaxes
	,convert(varchar(60),SumOfPayments) as SumOfPayments
	,convert(varchar(60),SumOfRefunds) as SumOfRefunds
	,convert(varchar(60),SumOfCreditNotes) as SumOfCreditNotes
	,convert(varchar(60),SumOfDiscounts) as SumOfDiscounts
	,convert(varchar(60),SumOfCharges) as SumOfCharges
from 
	ReverseCharge rc inner join 
	Charge ch on rc.OriginalChargeId = ch.Id
	inner join FirstInvoiceCluster rr 
	on ch.InvoiceId = rr.InvoiceId 
	inner join LatestInvoiceJournal lij on rr.InvoiceId = lij.InvoiceId
	inner join InvoiceJournal ij on lij.Id = ij.Id
	inner join [Transaction] t 
	on rc.Id = t.Id
	inner join PurchaseCharge pc 
	on ch.Id = pc.Id
	inner join Purchase pu on pu.Id = pc.PurchaseId
	inner join Product p 
	on pu.ProductId = p.Id 
	inner join Customer c on pu.CustomerId = c.Id
	inner join CustomerReference cr on c.id = cr.Id
	inner join AccountPreference ap
	on c.AccountId = ap.Id
	left join SalesTrackingCode stc1 on cr.SalesTrackingCode1Id = stc1.Id
	left join SalesTrackingCode stc4 on cr.SalesTrackingCode4Id = stc4.Id
	left join SalesTrackingCode stc2 on cr.SalesTrackingCode2Id = stc2.Id
	left join SalesTrackingCode stc3 on cr.SalesTrackingCode3Id = stc3.Id
	left join SalesTrackingCode stc5 on cr.SalesTrackingCode5Id = stc5.Id
	left join Address a on c.Id = a.CustomerAddressPreferenceId and a.AddressTypeId = 1
	left join Lookup.State ls on a.CountryId = ls.CountryId and a.StateId = ls.Id
where t.CreatedTimestamp  >=@StartDate 
	and t.CreatedTimestamp  < @EndDate 
	--check to see that the subscription is still active
	'

SET @SQL = @SQL +
	'
)Data
pivot
(Sum(Amount)
for Name in (' 

SET @SQL = @SQL + @PlanProductListPivot 

SET @SQL = @SQL + ')
)Pivottable
Order by InvoiceNumber
'	
exec sp_executesql @SQL

END

GO

