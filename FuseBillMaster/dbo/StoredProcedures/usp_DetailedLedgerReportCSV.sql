CREATE procedure [dbo].[usp_DetailedLedgerReportCSV]
@AccountId bigint 
,@UTCStartDateTime datetime 
,@UTCEndDateTime datetime 
,@CurrencyId bigint = 1
,@IncludeEarning int = 1

AS

if @UTCStartDateTime is null
	set @UTCStartDateTime = dateadd(month,-1,getutcdate())
if @UTCEndDateTime is null
	set @UTCEndDateTime = getutcdate()
Declare @SQL nvarchar (max)

set @Sql = '
set transaction isolation level snapshot

--Temp table to customer details
SELECT * INTO #CustomerData
FROM BasicCustomerDataByAccount(@AccountId)

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
	,[PaymentRecId] as [Payment Reconciliation ID]
	,[InvoiceNumber] as [Invoice Number]
	,Customer.*
  FROM
(
SELECT 
	tr.CustomerId
	,ap.TimezoneId
	,tr.id as TransactionID
	,tt.Name as TransactionType
	,isnull(Coalesce(chea.Name,ch.Name,pa.Reference,och.Name,taxr.Name,otr.Name,eroc.Name,drch.Name,''''),'''') as TransactionName
	,ISNULL(Coalesce(tr.Description, dtran.Description, rc.Reference, cred.Reference,wo.Reference, ''''),'''') as TransactionDescription
	,gl.Code as GLCode
	,tr.EffectiveTimestamp as LedgerDate
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
	,isnull(convert(varchar(255), paj.[ReconciliationId]), '''') as [PaymentRecId]
	,Coalesce(convert(varchar(255), inv.[InvoiceNumber]), invNumb.InvoiceNumbers, invNumbCred.InvoiceNumbers, '''') as [InvoiceNumber]
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
	left join Refund re
	on tr.Id = re.Id	
	left join (SELECT 
		PaymentId
		,STUFF(
			(SELECT '','' + CONVERT(VARCHAR(20),i.InvoiceNumber)
			FROM PaymentNote pn2
			JOIN Invoice i ON pn2.InvoiceId = i.Id
			WHERE pn2.PaymentId = pn.PaymentId
			ORDER BY InvoiceNumber
				FOR XML PATH('''')),1,1,'''') AS InvoiceNumbers
		FROM PaymentNote pn
		GROUP BY PaymentId) invNumb
	on invNumb.PaymentId = coalesce(pa.Id, re.[OriginalPaymentId] )
	left join [PaymentActivityJournal] paj
	on paj.Id = IsNull(pa.PaymentActivityJournalId, re.PaymentActivityJournalId)
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
	left join (SELECT 
		CreditId
		,STUFF(
			(SELECT '','' + CONVERT(VARCHAR(20),i.InvoiceNumber)
			FROM CreditAllocation cn2
			JOIN Invoice i ON cn2.InvoiceId = i.Id
			WHERE cn2.CreditId = cn.CreditId
			ORDER BY InvoiceNumber
				FOR XML PATH('''')),1,1,'''') AS InvoiceNumbers
		FROM CreditAllocation cn
		GROUP BY CreditId) invNumbCred
	on invNumbCred.CreditId = cred.Id
	left join GLCode gl on COALESCE(odr.GlCodeId, eeodr.GlCodeId, ch.GLCodeId, drch.GLCodeId, chea.GLCodeId, och.GLCodeId, eroc.GLCodeId) = gl.Id
	left join [dbo].[WriteOff] wo 
	on tr.id = wo.Id
	left join Invoice inv 
	on COALESCE(ch.[InvoiceId], drch.[InvoiceId], chea.[InvoiceId], och.[InvoiceId], eroc.[InvoiceId], wo.[InvoiceId], tax.InvoiceId, otax.InvoiceId) = inv.Id
where 
	tr.AccountId = @AccountId 
	and tr.EffectiveTimestamp >= @UTCStartDateTime 
	and tr.EffectiveTimestamp < @UTCEndDateTime  
	and tr.CurrencyId = @CurrencyId
	
'
if @IncludeEarning = 0
set @SQL = @SQL + ' and tr.TransactionTypeId not in  (6,9,23,27) '
set @SQL = @SQL + ')Data
INNER JOIN #CustomerData Customer ON Customer.[Fusebill ID] = Data.CustomerId
Order by LedgerDate
,TransactionId

DROP TABLE #CustomerData
'

execute sp_executesql @SQL, N'@AccountId bigint,@UTCStartDateTime datetime ,@UTCEndDateTime datetime ,@CurrencyId bigint',@AccountId ,@UTCStartDateTime ,@UTCEndDateTime,@CurrencyId --with recompile

GO

