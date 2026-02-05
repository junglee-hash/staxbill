CREATE PROCEDURE [Reporting].[Twinspires_MonthlySummary_v2]
	@AccountId bigint 
	,@StartDate datetime 
	,@EndDate datetime 
AS
BEGIN


set nocount on

set transaction isolation level snapshot

--Dates in Reporting.Twinspires_DailyActivityDetails are stored in Twinspires account timezone, no conversion needed

;with HasCredits as
(
Select InvoiceId, sum(Amount) as Amount
from CreditAllocation
Group by InvoiceId
)
select
	ISNULL(AffiliateId,'') as AffiliateId
	,Code as ProductCode
	,convert(varchar(60),Sum(CONVERT(decimal(18,0),Id)) ) as TotalCount
	,convert(varchar(60),Sum(isnull(CONVERT(decimal(18,2),Amount),0) ))as AmountCollected
	,convert(varchar(60),sum(case when (FiYB  = 'true' or FiYb like '%' + ISNULL(AffiliateId,'dont match') + '%') and TransactionAmount = 0 and AllowedAffiliates like '%2800%' then 1 else 0 end)) as FreeWithBet
from 
(
Select 
dad.[Product code] as Code
,case when ij.SumOfPayments != 0 then dad.[Actual Price Charged] * ch.Quantity when hc.Amount != 0 then dad.[Actual Price Charged] * ch.Quantity else 0 end as Amount
,stringValue
,cf.[Key]
,dad.[Actual Price Charged] * ch.Quantity as TransactionAmount
,ch.Quantity as Id
,dad.[Transaction ID] as TransactionId
,stc.Code as AffiliateId
from
	Charge ch
	inner join Reporting.Twinspires_DailyActivityDetails dad on dad.[Transaction ID] = ch.Id	
	inner join CustomerReference cr ON dad.FusebillId = cr.Id
	left join SalesTrackingCode stc ON stc.Id = cr.SalesTrackingCode1Id
	left join SubscriptionProductCustomField cpcf on dad.[Subscription Product ID] = cpcf.SubscriptionProductId 
	left join CustomField cf on cpcf.CustomFieldId = cf.Id 	and cf.[Key] in ('FiYB','AllowedAffiliates')
	inner join invoicejournal ij on ch.InvoiceId = ij.InvoiceId and ij.Isactive = 1
	left join HasCredits hc	on ch.InvoiceId = hc.InvoiceId
	
where 
	dad.[Transaction Date] >= @StartDate 
	and dad.[Transaction Date] < @EndDate 
	and ch.Quantity != 0
	and dad.AccountId = @AccountId
	and dad.[Purchase ID] is null
union all	

Select dad.[Product code] as Code
,case when ij.SumOfPayments != 0 then dad.[Actual Price Charged] * ch.Quantity when hc.Amount != 0 then dad.[Actual Price Charged] * ch.Quantity else 0 end as Amount
,stringValue
,cf.[Key]
,dad.[Actual Price Charged] * ch.Quantity as TransactionAmount
,ch.Quantity as Id
,dad.[Transaction Id] as TransactionId
,stc.Code as AffiliateId
from
	Charge ch
	inner join Reporting.Twinspires_DailyActivityDetails dad on dad.[Transaction ID] = ch.Id	
	inner join CustomerReference cr ON dad.FusebillId = cr.Id
	left join SalesTrackingCode stc ON stc.Id = cr.SalesTrackingCode1Id
	left join PurchaseCustomField pcf on dad.[Purchase ID]  = pcf.PurchaseId 
	left join CustomField cf on pcf.CustomFieldId = cf.Id and cf.[Key] in ('FiYB','AllowedAffiliates')
	inner join invoicejournal ij on ch.InvoiceId = ij.InvoiceId and ij.Isactive = 1
	left join HasCredits hc on ch.InvoiceId = hc.InvoiceId
where 
	 dad.[Transaction Date] >=@StartDate 
	and dad.[Transaction Date] < @EndDate 
	and ch.Quantity != 0
	and dad.AccountId = @AccountId
	and dad.[Subscription Product ID] is null

union all--reversals now

Select dad.[Product code] as Code
,case when ij.SumOfPayments != 0 then dad.[Actual Price Charged] when hc.Amount != 0 then dad.[Actual Price Charged] else 0 end as Amount
,stringValue
,cf.[Key]
,dad.[Actual Price Charged] as TransactionAmount
,-1 as Id
,dad.[Transaction ID] as TransactionId
,stc.Code as AffiliateId
from
	reversecharge rc
	inner join Charge ch on ch.Id = rc.OriginalChargeId
	inner join Reporting.Twinspires_DailyActivityDetails dad on dad.[Transaction ID] = ch.Id
	inner join CustomerReference cr ON dad.FusebillId = cr.Id
	left join SalesTrackingCode stc ON stc.Id = cr.SalesTrackingCode1Id
	left join SubscriptionProductCustomField cpcf on dad.[Subscription Product ID] = cpcf.SubscriptionProductId 
	left join CustomField cf on cpcf.CustomFieldId = cf.Id and cf.[Key] in ('FiYB','AllowedAffiliates')
	inner join invoicejournal ij on ch.InvoiceId = ij.InvoiceId and ij.Isactive = 1
	left join HasCredits hc on ch.InvoiceId = hc.InvoiceId
where 
	dad.[Transaction Date] >=@StartDate 
	and dad.[Transaction Date] < @EndDate 
	and ch.Quantity != 0
	and dad.AccountId = @AccountId
	and dad.[Purchase ID] is null

union all	

Select 
dad.[Product code] as Code
,case when ij.SumOfPayments != 0 then dad.[Actual Price Charged] when hc.Amount != 0 then dad.[Actual Price Charged] else 0 end as Amount
,stringValue
,cf.[Key]
,dad.[Actual Price Charged] as TransactionAmount
,-1 as Id
,dad.[Transaction ID] as TransactionId
,stc.Code as AffiliateId
from
	reversecharge rc
	inner join Charge ch on ch.Id = rc.OriginalChargeId
	inner join Reporting.Twinspires_DailyActivityDetails dad on dad.[Transaction ID] = ch.Id
	inner join CustomerReference cr ON dad.FusebillId = cr.Id
	left join SalesTrackingCode stc ON stc.Id = cr.SalesTrackingCode1Id
	left join PurchaseCustomField pcf on dad.[Purchase ID]  = pcf.PurchaseId 
	left join CustomField cf on pcf.CustomFieldId = cf.Id and cf.[Key] in ('FiYB','AllowedAffiliates')
	inner join invoicejournal ij on ch.InvoiceId = ij.InvoiceId and ij.Isactive = 1
	left join HasCredits hc on ch.InvoiceId = hc.InvoiceId
where 
	dad.[Transaction Date] >=@StartDate 
	and dad.[Transaction Date] < @EndDate 
	and ch.Quantity != 0
	and dad.AccountId = @AccountId
	and dad.[Subscription Product ID] is null
) data
Pivot
(
max(StringValue)
for [Key] in
(
[FiYB],[AllowedAffiliates]
)
)pivottable
group by code, AffiliateId

set nocount off
END

GO

