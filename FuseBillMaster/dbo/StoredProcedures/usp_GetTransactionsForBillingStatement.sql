-- =============================================
-- Author:		dlarkin
-- Create date: 2018-10-25
-- Description:	created to replace the multiple repo hits for billing statement related transactions
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetTransactionsForBillingStatement]
--declare
	@customerIds nvarchar(max) = '92657',
	@AccountId bigint = 81763,
	@StartDate datetime = '2017-01-01',
	@EndDate datetime = '2022-10-26',
	@IncludeTrackedItems bit = 1
AS
BEGIN

declare @customers table
(
CusId bigint
)

INSERT INTO @customers (CusId)
select 
[Data] 
FROM dbo.Split (@customerIds,'|')


SELECT *,
t.TransactionTypeId as TransactionType
 INTO #CustomerTransactions
	FROM [Transaction] t
	inner join @customers c on t.CustomerId = c.CusId
	WHERE 
	t.AccountId = @AccountId
	AND t.EffectiveTimestamp >= @StartDate
	AND t.EffectiveTimestamp <= @EndDate
	AND t.TransactionTypeId in (1,2,3,4,5,7,8,10,11,12,14,15,16,17,18,19,20,21,22,24,25, 28,29,30,31,32)

select *
from OpeningBalance ob
inner join #CustomerTransactions ct on ct.Id = ob.Id

select * 
from Refund r
inner join #CustomerTransactions ct on ct.Id = r.Id

select * from ReverseCharge rc
inner join #CustomerTransactions ct on ct.Id = rc.Id

select * from VoidReverseCharge vrc 
inner join #CustomerTransactions ct on ct.Id = vrc.Id

select * from VoidReverseDiscount vrd 
inner join #CustomerTransactions ct on ct.Id = vrd.Id

select * from VoidReverseTax vrt
inner join #CustomerTransactions ct on ct.Id = vrt.Id

select * from ReverseDiscount rd
inner join #CustomerTransactions ct on ct.Id = rd.Id

select * from ReverseTax rt
inner join #CustomerTransactions ct on ct.Id = rt.Id

select * from Debit d 
inner join #CustomerTransactions ct on ct.Id = d.Id

select * from WriteOff we
inner join #CustomerTransactions ct on ct.Id = we.Id

select ch.*,
ch.EarningTimingTypeId as [EarningTimingType],
ch.EarningTimingIntervalId as [EarningTimingInterval],
ct.* from Charge ch
inner join #CustomerTransactions ct on ct.Id = ch.Id

select cr.*,
ct.* from credit cr
inner join #CustomerTransactions ct on ct.Id = cr.Id

select p.*,
ct.* from Payment p
inner join #CustomerTransactions ct on ct.Id = p.Id

select d.*,
d.DiscountTypeId as [DiscountType],
ct.* from Discount d
inner join #CustomerTransactions ct on ct.Id = d.Id

select Tax.*,
ct.* from Tax 
inner join #CustomerTransactions ct on ct.Id = Tax.Id

select * from OpeningBalanceAllocation oba
inner join #CustomerTransactions ct on ct.Id = oba.OpeningBalanceId

select * from vw_CustomerLedgerJournal clj
inner join #CustomerTransactions ct on ct.Id = clj.TransactionId

select *
	,ps.StatusId as [Status]
from PaymentSchedule ps
inner join Charge ch on ch.InvoiceId = ps.InvoiceId
inner join #CustomerTransactions ct on ct.Id = ch.Id

select s.*
 ,s.[StatusId] as [Status]
 ,s.[IntervalId] as Interval
from Subscription s
inner join [ChargeGroup] cg on cg.SubscriptionId = s.Id
inner join [Charge] ch on ch.ChargeGroupId = cg.Id
inner join #CustomerTransactions ct on ct.Id = ch.Id

select p.*
	,p.EarningTimingIntervalId as EarningTimingInterval
	,p.EarningTimingTypeId as EarningTimingType
	,p.PricingFormulaTypeId as PricingFormulaType
	,p.PricingModelTypeId as PricingModelType
	,p.StatusId as [Status]
from Purchase p
inner join PurchaseCharge pc on pc.PurchaseId = p.Id
inner join #CustomerTransactions ct on ct.Id = pc.Id

select *,
psj.StatusId as [Status]
 from PaymentScheduleJournal psj
inner join PaymentSchedule ps on psj.PaymentScheduleId = ps.Id
inner join Charge ch on ch.InvoiceId = ps.InvoiceId
inner join #CustomerTransactions ct on ct.Id = ch.Id
where psj.IsActive = 1

select * from ChargeProductItem cpi
inner join ProductItem pri on pri.Id = cpi.ProductItemId
inner join Product pro on pro.Id = pri.ProductId
inner join #CustomerTransactions ct on ct.Id = cpi.ChargeId
where pro.AccountId = @AccountId
and @IncludeTrackedItems = 1

select *,
 pri.StatusId as [Status] from ProductItem pri
inner join ChargeProductItem cpi on pri.Id = cpi.ProductItemId
inner join Product pro on pro.Id = pri.ProductId
inner join #CustomerTransactions ct on ct.Id = cpi.ChargeId
where pro.AccountId = @AccountId
and @IncludeTrackedItems = 1

select pc.* from PurchaseCharge pc
inner join Charge ch on ch.Id = pc.Id
inner join #CustomerTransactions ct on ct.Id = ch.Id 

select cht.* from ChargeTier cht 
inner join Charge ch on ch.Id = cht.ChargeId
inner join #CustomerTransactions ct on ct.Id = ch.Id 

select pn.* from PaymentNote pn 
inner join payment p on p.Id = pn.PaymentId
inner join #CustomerTransactions ct on ct.Id = p.Id

select rn.* from RefundNote rn 
inner join Refund r on r.Id = rn.RefundId
inner join #CustomerTransactions ct on ct.Id = r.Id

select tr.* from TaxRule tr
inner join Tax on Tax.TaxRuleId = tr.Id
inner join ReverseTax rt on rt.OriginalTaxId = Tax.Id
inner join #CustomerTransactions ct on ct.Id = rt.ReverseChargeId

select * from CreditAllocation ca
inner join #CustomerTransactions ct on ct.Id = ca.CreditId

select * from DebitAllocation da
inner join #CustomerTransactions ct on ct.Id = da.DebitId


/*** invoices ****/

select i.* from Invoice i
inner join Charge ch on ch.InvoiceId = i.Id
inner join #CustomerTransactions ct on ct.Id = ch.Id

union 

select i.* from Invoice i
inner join PaymentNote pn on pn.InvoiceId = i.Id
inner join #CustomerTransactions ct on ct.Id = pn.PaymentId

union 

select i.* from Invoice i
inner join RefundNote rn on rn.InvoiceId = i.Id
inner join #CustomerTransactions ct on ct.Id = rn.RefundId

union 

select i.* from Invoice i
inner join Charge ch on ch.InvoiceId = i.Id
inner join ReverseCharge rc on rc.OriginalChargeId = ch.Id
inner join #CustomerTransactions ct on ct.Id = rc.Id

union 

select i.* from Invoice i
inner join CreditAllocation ca on ca.InvoiceId = i.Id
inner join  #CustomerTransactions ct on ct.Id = ca.CreditId

union 

select i.* from Invoice i
inner join DebitAllocation da on da.InvoiceId = i.Id
inner join  #CustomerTransactions ct on ct.Id = da.DebitId

union 

select i.* from Invoice i
inner join WriteOff wr on wr.InvoiceId = i.Id
inner join #CustomerTransactions ct on ct.Id = wr.Id

/*** invoices end ****/

/*** paj ****/

select paj.*, 
paj.PaymentSourceId as [PaymentSource],
paj.PaymentActivityStatusId as [PaymentActivityStatus],
paj.PaymentTypeId as [PaymentType],
paj.PaymentMethodTypeId as [PaymentMethodType],
paj.PaymentTypeId as [PaymentType],
paj.SettlementStatusId as [SettlementStatus],
paj.DisputeStatusId as [DisputeStatus]
from PaymentActivityJournal paj
inner join Payment p on p.PaymentActivityJournalId = paj.Id
inner join #CustomerTransactions ct on ct.Id = p.Id

union 

select paj.*, 
paj.PaymentSourceId as [PaymentSource],
paj.PaymentActivityStatusId as [PaymentActivityStatus],
paj.PaymentTypeId as [PaymentType],
paj.PaymentMethodTypeId as [PaymentMethodType],
paj.PaymentTypeId as [PaymentType],
paj.SettlementStatusId as [SettlementStatus],
paj.DisputeStatusId as [DisputeStatus]
 from PaymentActivityJournal paj
inner join Refund r on r.PaymentActivityJournalId = paj.Id
inner join #CustomerTransactions ct on ct.Id = r.Id

/*** paj end ****/

/*** charge group ****/

select cg.* from ChargeGroup cg
inner join Charge ch on ch.ChargeGroupId = cg.Id
inner join #CustomerTransactions ct on ct.Id = ch.Id

union

select cg.* from ChargeGroup cg
inner join Charge ch on ch.ChargeGroupId = cg.Id
inner join ReverseCharge rc on rc.OriginalChargeId = ch.Id
inner join #CustomerTransactions ct on ct.Id = rc.Id

/*** charge group end ****/

/*** subscription product charge ****/

select spc.*,
ct.* from SubscriptionProductCharge spc
inner join #CustomerTransactions ct on ct.Id = spc.Id

/*** subscription product charge end ****/

drop table #CustomerTransactions
END

GO

