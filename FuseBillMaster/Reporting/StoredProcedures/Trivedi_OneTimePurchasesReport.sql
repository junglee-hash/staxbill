
CREATE procedure [Reporting].[Trivedi_OneTimePurchasesReport]
@AccountId bigint = 21587
,@StartDate DATETIME
,@EndDate DATETIME 
AS

DECLARE @TimezoneId int
	,@CurrencyId int = 1
	
select 
	@TimezoneId = TimezoneId
	,@StartDate = dbo.fn_GetUtcTime(@StartDate,TimezoneId)
	,@EndDate = dbo.fn_GetUtcTime(@EndDate,TimezoneId)
from AccountPreference 
where Id = @AccountId


set transaction isolation level snapshot
 select  
	TransactionID as [Transaction ID]
	,TransactionType as [Transaction Type]
	,TransactionName as [Transaction Name]
	,TransactionDescription as [Transaction Description]
	,GLCode as [GL Code]
	,convert(datetime,dbo.fn_GetTimezoneTime (LedgerDate,TimezoneId)) as [Ledger Date]
	,[Currency]
	,isnull([AR balance],0) as [AR Balance]
	,isnull([Cash collected],0) as [Cash Collected]
	,isnull([Earned revenue],0) as [Earned Revenue]
	,isnull([Deferred revenue],0) as [Deferred Revenue]
	,isnull([Taxes payable],0) as [Taxes Payable]
	,isnull([Discount],0) as [Discount]
	,isnull([Deferred Discount],0) as [Deferred Discount]
	,isnull([Write off],0) as [Write Off]
	,isnull([Credit],0) as [Credit]
	,isnull([Opening Balance],0) as [Opening Balance]
	,isnull([Opening Deferred Revenue Balance],0) as [Opening Deferred Revenue Balance]
	,c.Id as [Fusebill ID]
	,isnull(c.Reference,'') as [Customer ID]
	,isnull(c.FirstName,'') as  [Customer First Name]
	,isnull(c.LastName,'') as [Customer Last Name]
	,isnull(c.CompanyName,'') as [Customer Company Name]
	,isnull(c.PrimaryEmail,'') as [Customer Primary Email]
  FROM
(
SELECT 
	tr.CustomerId
	,ap.TimezoneId
	,tr.id as TransactionID
	,tt.Name as TransactionType
	,isnull(Coalesce(chea.Name,ch.Name,pa.Reference,och.Name,taxr.Name,otr.Name,eroc.Name,drch.Name,''''),'''') as TransactionName
	,ISNULL(Coalesce(tr.Description, dtran.Description, rc.Reference,''''),'''') as TransactionDescription
	,gl.Code as GLCode
	,coalesce(convert(nvarchar,dbo.fn_GetTimezoneTime (tr.EffectiveTimestamp,@TimezoneId),120),'') as LedgerDate
	,cur.IsoName as [Currency]
	,le.ArDebit-le.ArCredit as [AR balance]
	,le.CashDebit- le.CashCredit as [Cash collected]
	,le.EarnedDebit- le.EarnedCredit as [Earned revenue]
	,le.UnearnedDebit- le.UnearnedCredit as [Deferred revenue]
	,le.TaxesPayableDebit-le.TaxesPayableCredit as [Taxes payable]
	,le.DiscountDebit- le.DiscountCredit as [Discount]
	,le.UnearnedDiscountDebit- le.UnearnedDiscountCredit as [Deferred Discount]
	,le.WriteOffDebit- le.WriteOffCredit as [Write off]
	,le.CreditDebit - le.CreditCredit as [Credit]
	,le.OpeningBalanceDebit  - le.OpeningBalanceCredit  as [Opening Balance]
	,le.OpeningDeferredRevenueDebit - OpeningDeferredRevenueCredit as [Opening Deferred Revenue Balance]
from 
	 vw_CustomerLedgerJournal LE 
	 inner join [Transaction] tr
	 on le.TransactionId = tr.id 
	 inner join lookup.TransactionType tt
	 on tr.TransactionTypeId = tt.Id
	inner join AccountPreference ap
	on tr.AccountId = ap.id
	inner join Lookup.Currency cur ON cur.Id = tr.CurrencyId
	left join OpeningDeferredRevenue odr on tr.Id = odr.Id
	left join EarningOpeningDeferredRevenue eodr on tr.Id = eodr.Id
	left join OpeningDeferredRevenue eeodr on eeodr.Id = eodr.OpeningDeferredRevenueId
	left join Charge ch
	on tr.Id = ch.Id
	left join Earning ea
	on tr.Id = ea.Id
	left join Charge chea
	on ea.ChargeId = chea.Id
	left join ReverseCharge rc
	on tr.Id = rc.Id
	left join Charge och
	on rc.OriginalChargeId = och.Id
	left join Tax tax
	on tr.Id = Tax.Id
	left join TaxRule taxr
	on tax.TaxRuleId = taxr.Id 
	left join ReverseTax revt
	on tr.Id = revt.Id
	left join Tax otax
	on revt.OriginalTaxId = otax.Id 
	left join TaxRule otr
	on otax.TaxRuleId = otr.Id 
	left join ReverseEarning rea
	on tr.Id = rea.Id
	left join ReverseCharge erc
	on rea.ReverseChargeId = erc.Id 
	left join Charge eroc
	on erc.OriginalChargeId = eroc.Id 
	left join Payment pa
	on tr.Id = pa.Id	
	left join ReverseDiscount rd
	on tr.Id = rd.Id
	left join EarningDiscount ed
	on ed.id = tr.id
	left join Discount dr
	on coalesce (ed.DiscountId, rd.OriginalDiscountId, tr.Id) = dr.Id
	left join Charge drch
	on dr.ChargeId = drch.Id
	left join [Transaction] dtran on dtran.Id = COALESCE(dr.Id,eeodr.Id,chea.Id)
	left join SubscriptionProductCharge spc
	on Coalesce(chea.Id,ch.Id,och.Id,eroc.Id,drch.Id) = spc.Id
	left join SubscriptionProduct  spr
	on spc.SubscriptionProductId = spr.Id
	left join Subscription sub
	on spr.SubscriptionId = sub.Id
	left join Credit cred
	on tr.Id = cred.Id
	left join GLCode gl on COALESCE(odr.GlCodeId, eeodr.GlCodeId, ch.GLCodeId, drch.GLCodeId, chea.GLCodeId, och.GLCodeId, eroc.GLCodeId) = gl.Id
where  
	ap.Id = @AccountId 
	and tr.EffectiveTimestamp >= @StartDate 
	and tr.EffectiveTimestamp < @EndDate
	and (tr.TransactionTypeId = 20 or (tr.TransactionTypeId = 6 and spc.id is null))
) data
inner join Customer c ON data.CustomerId = c.Id
order by LedgerDate, [Transaction Type] desc

GO

