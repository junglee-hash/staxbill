
CREATE PROCEDURE [Reporting].[EvolutionWireless_ProductRevenue]
	@AccountId BIGINT 
	,@StartDate DATETIME
	,@EndDate DATETIME 
AS
BEGIN
DECLARE @TimezoneId int
	
	
set nocount on
set transaction isolation level snapshot
	
select @EndDate = dbo.fn_GetUtcTime(@EndDate,TimezoneId)
,@StartDate = dbo.fn_GetUtcTime(@StartDate,TimezoneId)
,@TimezoneId = TimezoneId
from AccountPreference 
where Id = @AccountId

declare @Results table
(
ProductId bigint
,ProductCode nvarchar(255)
,GLCodeId int
,ProductName nvarchar(255)
,CustomerId bigint
,Date date
,ChargeId bigint
,ChargeDate datetime
,[ArDebit] decimal (18,2)
      ,[ArCredit] decimal (18,2)
      ,[CashDebit] decimal (18,2)
      ,[CashCredit] decimal (18,2)
      ,[UnearnedDebit] decimal (18,2)
      ,[UnearnedCredit] decimal (18,2)
      ,[EarnedDebit] decimal (18,2)
      ,[EarnedCredit] decimal (18,2)
      ,[WriteOffDebit] decimal (18,2)
      ,[WriteOffCredit] decimal (18,2)
      ,[TaxesPayableDebit] decimal (18,2)
      ,[TaxesPayableCredit] decimal (18,2)
      ,[DiscountDebit] decimal (18,2)
      ,[DiscountCredit] decimal (18,2)
      ,[OpeningBalanceDebit] decimal (18,2)
      ,[OpeningBalanceCredit] decimal (18,2)
      ,[CreditDebit] decimal (18,2)
      ,[CreditCredit] decimal (18,2)
      ,[UnearnedDiscountDebit] decimal (18,2)
      ,[UnearnedDiscountCredit] decimal (18,2)
	  ,RevenueCharged decimal(18,2)
	  ,DiscountCharged decimal(18,2)
	  ,ReversedCharge decimal(18,2)
	  ,ReversedDiscount decimal(18,2)

)

Insert into @Results
(
ProductId 
,ProductCode 
,GLCodeId 
,ProductName 
,CustomerId
,Date 
,ChargeId
,ChargeDate
,[ArDebit]
      ,[ArCredit]
      ,[CashDebit]
      ,[CashCredit]
      ,[UnearnedDebit]
      ,[UnearnedCredit]
      ,[EarnedDebit]
      ,[EarnedCredit]
      ,[WriteOffDebit]
      ,[WriteOffCredit]
      ,[TaxesPayableDebit]
      ,[TaxesPayableCredit]
      ,[DiscountDebit]
      ,[DiscountCredit]
      ,[OpeningBalanceDebit]
      ,[OpeningBalanceCredit]
      ,[CreditDebit]
      ,[CreditCredit]
      ,[UnearnedDiscountDebit]
      ,[UnearnedDiscountCredit]
	  ,RevenueCharged 
	  ,DiscountCharged
	  ,ReversedCharge 
	  ,ReversedDiscount 
)
select 
	pr.Id
	,pr.Code
	,pr.GLCodeId
	,pr.Name
	,t.customerid 
	,convert(date,dbo.fn_GetTimezoneTime(t.CreatedTimestamp,@TimezoneId) ) as Date
	,ct.Id as ChargeId
	,convert(date,dbo.fn_getTimezoneTime(ct.CreatedTimestamp,@TimezoneId )) as ChargeDate
,[ArDebit]
      ,[ArCredit]
      ,[CashDebit]
      ,[CashCredit]
      ,[UnearnedDebit]
      ,[UnearnedCredit]
      ,[EarnedDebit]
      ,[EarnedCredit]
      ,[WriteOffDebit]
      ,[WriteOffCredit]
      ,[TaxesPayableDebit]
      ,[TaxesPayableCredit]
      ,[DiscountDebit]
      ,[DiscountCredit]
      ,[OpeningBalanceDebit]
      ,[OpeningBalanceCredit]
      ,[CreditDebit]
      ,[CreditCredit]
      ,[UnearnedDiscountDebit]
      ,[UnearnedDiscountCredit]
	  ,t.Amount as RevenueCharged 
	  ,0 as DiscountCharged
	  ,0 as ReversedCharge 
	  ,0 as ReversedDiscount 
	
from 
	[Transaction] t with (nolock)
	inner join charge ch with (nolock)
	on t.Id = ch.Id
	inner join SubscriptionProductcharge spc with (nolock) on ch.Id = spc.Id 
	inner join SubscriptionProduct sp with (nolock) on spc.SubscriptionProductId = sp.Id
	inner join Product pr with (nolock) on sp.ProductId = pr.Id
	inner join vw_CustomerLedgerJournal clj with (nolock) on t.Id = clj.TransactionId
	inner join [Transaction] ct with (nolock) on ch.Id = ct.Id
where 
	pr.AccountId = @AccountId
	and t.CreatedTimestamp >= @StartDate
	and t.CreatedTimestamp < @EndDate

union all
select 
	pr.Id
	,pr.Code
	,pr.GLCodeId
	,pr.Name
	,t.customerid 
	,convert(date,dbo.fn_GetTimezoneTime(t.CreatedTimestamp,@TimezoneId) ) as Date
	,ct.Id as ChargeId
	,convert(date,dbo.fn_getTimezoneTime(ct.CreatedTimestamp,@TimezoneId )) as ChargeDate
,[ArDebit]
      ,[ArCredit]
      ,[CashDebit]
      ,[CashCredit]
      ,[UnearnedDebit]
      ,[UnearnedCredit]
      ,[EarnedDebit]
      ,[EarnedCredit]
      ,[WriteOffDebit]
      ,[WriteOffCredit]
      ,[TaxesPayableDebit]
      ,[TaxesPayableCredit]
      ,[DiscountDebit]
      ,[DiscountCredit]
      ,[OpeningBalanceDebit]
      ,[OpeningBalanceCredit]
      ,[CreditDebit]
      ,[CreditCredit]
      ,[UnearnedDiscountDebit]
      ,[UnearnedDiscountCredit]
	  ,t.Amount as RevenueCharged 
	  ,0 as DiscountCharged
	  ,0 as ReversedCharge 
	  ,0 as ReversedDiscount 
from 
	[Transaction] t with (nolock)
	inner join charge ch with (nolock)
	on t.Id = ch.Id
	inner join PurchaseCharge spc with (nolock) on ch.Id = spc.Id 
	inner join Purchase sp with (nolock) on spc.PurchaseId = sp.Id
	inner join Product pr with (nolock) on sp.ProductId = pr.Id
	inner join vw_CustomerLedgerJournal clj with (nolock) on t.Id = clj.TransactionId
	inner join [Transaction] ct with (nolock) on ch.Id = ct.Id
where 
	pr.AccountId = @AccountId
	and t.CreatedTimestamp >= @StartDate
	and t.CreatedTimestamp < @EndDate

--discounts
union all
select 
	pr.Id
	,pr.Code
	,pr.GLCodeId
	,pr.Name
	,t.customerid 
	,convert(date,dbo.fn_GetTimezoneTime(t.CreatedTimestamp,@TimezoneId) ) as Date
	,ct.Id as ChargeId
	,convert(date,dbo.fn_getTimezoneTime(ct.CreatedTimestamp,@TimezoneId )) as ChargeDate
,[ArDebit]
      ,[ArCredit]
      ,[CashDebit]
      ,[CashCredit]
      ,[UnearnedDebit]
      ,[UnearnedCredit]
      ,[EarnedDebit]
      ,[EarnedCredit]
      ,[WriteOffDebit]
      ,[WriteOffCredit]
      ,[TaxesPayableDebit]
      ,[TaxesPayableCredit]
      ,[DiscountDebit]
      ,[DiscountCredit]
      ,[OpeningBalanceDebit]
      ,[OpeningBalanceCredit]
      ,[CreditDebit]
      ,[CreditCredit]
      ,[UnearnedDiscountDebit]
      ,[UnearnedDiscountCredit]
	  ,0 as RevenueCharged 
	  ,t.Amount as DiscountCharged
	  ,0 as ReversedCharge 
	  ,0 as ReversedDiscount 
from 
	[Transaction] t with (nolock)
	inner join discount d with (nolock)
	on t.Id = d.Id 
	inner join charge ch with (nolock)
	on d.ChargeId = ch.Id
	inner join SubscriptionProductcharge spc with (nolock) on ch.Id = spc.Id 
	inner join SubscriptionProduct sp with (nolock) on spc.SubscriptionProductId = sp.Id
	inner join Product pr with (nolock) on sp.ProductId = pr.Id
	inner join vw_CustomerLedgerJournal clj with (nolock) on t.Id = clj.TransactionId
	inner join [Transaction] ct with (nolock) on ch.Id = ct.Id
where 
	pr.AccountId = @AccountId
	and t.CreatedTimestamp >= @StartDate
	and t.CreatedTimestamp < @EndDate

union all
select 
	pr.Id
	,pr.Code
	,pr.GLCodeId
	,pr.Name
	,t.customerid 
	,convert(date,dbo.fn_GetTimezoneTime(t.CreatedTimestamp,@TimezoneId) ) as Date
	,ct.Id as ChargeId
	,convert(date,dbo.fn_getTimezoneTime(ct.CreatedTimestamp,@TimezoneId )) as ChargeDate
,[ArDebit]
      ,[ArCredit]
      ,[CashDebit]
      ,[CashCredit]
      ,[UnearnedDebit]
      ,[UnearnedCredit]
      ,[EarnedDebit]
      ,[EarnedCredit]
      ,[WriteOffDebit]
      ,[WriteOffCredit]
      ,[TaxesPayableDebit]
      ,[TaxesPayableCredit]
      ,[DiscountDebit]
      ,[DiscountCredit]
      ,[OpeningBalanceDebit]
      ,[OpeningBalanceCredit]
      ,[CreditDebit]
      ,[CreditCredit]
      ,[UnearnedDiscountDebit]
      ,[UnearnedDiscountCredit]
	  ,0 as RevenueCharged 
	  ,t.Amount as DiscountCharged
	  ,0 as ReversedCharge 
	  ,0 as ReversedDiscount 
from 
	[Transaction] t with (nolock)
	inner join discount d with (nolock)
	on t.Id = d.Id 
	inner join charge ch with (nolock)
	on d.ChargeId = ch.Id
	inner join PurchaseCharge spc with (nolock) on ch.Id = spc.Id 
	inner join Purchase sp with (nolock) on spc.PurchaseId = sp.Id
	inner join Product pr with (nolock) on sp.ProductId = pr.Id
	inner join vw_CustomerLedgerJournal clj with (nolock) on t.Id = clj.TransactionId
	inner join [Transaction] ct with (nolock) on ch.Id = ct.Id
where 
	pr.AccountId = @AccountId
	and t.CreatedTimestamp >= @StartDate
	and t.CreatedTimestamp < @EndDate

--reversecharge
union all
select 
	pr.Id
	,pr.Code
	,pr.GLCodeId
	,pr.Name
	,t.customerid 
	,convert(date,dbo.fn_GetTimezoneTime(t.CreatedTimestamp,@TimezoneId) ) as Date
	,ct.Id as ChargeId
	,convert(date,dbo.fn_getTimezoneTime(ct.CreatedTimestamp,@TimezoneId )) as ChargeDate
,[ArDebit]
      ,[ArCredit]
      ,[CashDebit]
      ,[CashCredit]
      ,[UnearnedDebit]
      ,[UnearnedCredit]
      ,[EarnedDebit]
      ,[EarnedCredit]
      ,[WriteOffDebit]
      ,[WriteOffCredit]
      ,[TaxesPayableDebit]
      ,[TaxesPayableCredit]
      ,[DiscountDebit]
      ,[DiscountCredit]
      ,[OpeningBalanceDebit]
      ,[OpeningBalanceCredit]
      ,[CreditDebit]
      ,[CreditCredit]
      ,[UnearnedDiscountDebit]
      ,[UnearnedDiscountCredit]
	  ,0 as RevenueCharged 
	  ,0 as DiscountCharged
	  ,-t.Amount as ReversedCharge 
	  ,0 as ReversedDiscount 
from 
	[Transaction] t with (nolock)
	inner join ReverseCharge rc with (nolock)
	on t.Id = rc.Id 
	inner join charge ch with (nolock)
	on rc.OriginalChargeId = ch.Id
	inner join SubscriptionProductcharge spc with (nolock) on ch.Id = spc.Id 
	inner join SubscriptionProduct sp with (nolock) on spc.SubscriptionProductId = sp.Id
	inner join Product pr with (nolock) on sp.ProductId = pr.Id
	inner join vw_CustomerLedgerJournal clj with (nolock) on t.Id = clj.TransactionId
	inner join [Transaction] ct with (nolock) on ch.Id = ct.Id
where 
	pr.AccountId = @AccountId
	and t.CreatedTimestamp >= @StartDate
	and t.CreatedTimestamp < @EndDate

union all
select 
	pr.Id
	,pr.Code
	,pr.GLCodeId
	,pr.Name
	,t.customerid 
	,convert(date,dbo.fn_GetTimezoneTime(t.CreatedTimestamp,@TimezoneId) ) as Date
	,ct.Id as ChargeId
	,convert(date,dbo.fn_getTimezoneTime(ct.CreatedTimestamp,@TimezoneId )) as ChargeDate
,[ArDebit]
      ,[ArCredit]
      ,[CashDebit]
      ,[CashCredit]
      ,[UnearnedDebit]
      ,[UnearnedCredit]
      ,[EarnedDebit]
      ,[EarnedCredit]
      ,[WriteOffDebit]
      ,[WriteOffCredit]
      ,[TaxesPayableDebit]
      ,[TaxesPayableCredit]
      ,[DiscountDebit]
      ,[DiscountCredit]
      ,[OpeningBalanceDebit]
      ,[OpeningBalanceCredit]
      ,[CreditDebit]
      ,[CreditCredit]
      ,[UnearnedDiscountDebit]
      ,[UnearnedDiscountCredit]
	   ,0 as RevenueCharged 
	  ,0 as DiscountCharged
	  ,-t.Amount as ReversedCharge 
	  ,0 as ReversedDiscount 
from 
	[Transaction] t with (nolock)
	inner join ReverseCharge rc with (nolock)
	on t.Id = rc.Id 
	inner join charge ch with (nolock)
	on rc.OriginalChargeId = ch.Id
	inner join PurchaseCharge spc with (nolock) on ch.Id = spc.Id 
	inner join Purchase sp with (nolock) on spc.PurchaseId = sp.Id
	inner join Product pr with (nolock) on sp.ProductId = pr.Id
	inner join vw_CustomerLedgerJournal clj with (nolock) on t.Id = clj.TransactionId
	inner join [Transaction] ct with (nolock) on ch.Id = ct.Id
where 
	pr.AccountId = @AccountId
	and t.CreatedTimestamp >= @StartDate
	and t.CreatedTimestamp < @EndDate
	
--reversediscount
union all
select 
	pr.Id
	,pr.Code
	,pr.GLCodeId
	,pr.Name
	,t.customerid 
	,convert(date,dbo.fn_GetTimezoneTime(t.CreatedTimestamp,@TimezoneId) ) as Date
	,ct.Id as ChargeId
	,convert(date,dbo.fn_getTimezoneTime(ct.CreatedTimestamp,@TimezoneId )) as ChargeDate
,[ArDebit]
      ,[ArCredit]
      ,[CashDebit]
      ,[CashCredit]
      ,[UnearnedDebit]
      ,[UnearnedCredit]
      ,[EarnedDebit]
      ,[EarnedCredit]
      ,[WriteOffDebit]
      ,[WriteOffCredit]
      ,[TaxesPayableDebit]
      ,[TaxesPayableCredit]
      ,[DiscountDebit]
      ,[DiscountCredit]
      ,[OpeningBalanceDebit]
      ,[OpeningBalanceCredit]
      ,[CreditDebit]
      ,[CreditCredit]
      ,[UnearnedDiscountDebit]
      ,[UnearnedDiscountCredit]
	   ,0 as RevenueCharged 
	  ,0 as DiscountCharged
	  ,0 as ReversedCharge 
	  ,-t.Amount as ReversedDiscount 
from 
	[Transaction] t with (nolock)
	inner join ReverseDiscount rd with (nolock)
	on t.Id = rd.Id 
	inner join ReverseCharge rc 
	on rd.ReverseChargeId = rc.Id
	inner join charge ch with (nolock)
	on rc.OriginalChargeId = ch.Id
	inner join SubscriptionProductcharge spc with (nolock) on ch.Id = spc.Id 
	inner join SubscriptionProduct sp with (nolock) on spc.SubscriptionProductId = sp.Id
	inner join Product pr with (nolock) on sp.ProductId = pr.Id
	inner join vw_CustomerLedgerJournal clj with (nolock) on t.Id = clj.TransactionId
	inner join [Transaction] ct with (nolock) on ch.Id = ct.Id
where 
	pr.AccountId = @AccountId
	and t.CreatedTimestamp >= @StartDate
	and t.CreatedTimestamp < @EndDate

union all
select 
	pr.Id
	,pr.Code
	,pr.GLCodeId
	,pr.Name
	,t.customerid 
	,convert(date,dbo.fn_GetTimezoneTime(t.CreatedTimestamp,@TimezoneId) ) as Date
	,ct.Id as ChargeId
	,convert(date,dbo.fn_getTimezoneTime(ct.CreatedTimestamp,@TimezoneId )) as ChargeDate
,[ArDebit]
      ,[ArCredit]
      ,[CashDebit]
      ,[CashCredit]
      ,[UnearnedDebit]
      ,[UnearnedCredit]
      ,[EarnedDebit]
      ,[EarnedCredit]
      ,[WriteOffDebit]
      ,[WriteOffCredit]
      ,[TaxesPayableDebit]
      ,[TaxesPayableCredit]
      ,[DiscountDebit]
      ,[DiscountCredit]
      ,[OpeningBalanceDebit]
      ,[OpeningBalanceCredit]
      ,[CreditDebit]
      ,[CreditCredit]
      ,[UnearnedDiscountDebit]
      ,[UnearnedDiscountCredit]
	   ,0 as RevenueCharged 
	  ,0 as DiscountCharged
	  ,0 as ReversedCharge 
	  ,-t.Amount as ReversedDiscount 
from 
	[Transaction] t with (nolock)
	inner join ReverseDiscount rd with (nolock)
	on t.Id = rd.Id 
	inner join ReverseCharge rc 
	on rd.ReverseChargeId = rc.Id
	inner join charge ch with (nolock)
	on rc.OriginalChargeId = ch.Id
	inner join PurchaseCharge spc with (nolock) on ch.Id = spc.Id 
	inner join Purchase sp with (nolock) on spc.PurchaseId = sp.Id
	inner join Product pr with (nolock) on sp.ProductId = pr.Id
	inner join vw_CustomerLedgerJournal clj with (nolock) on t.Id = clj.TransactionId
	inner join [Transaction] ct  with (nolock) on ch.Id = ct.Id
where 
	pr.AccountId = @AccountId
	and t.CreatedTimestamp >= @StartDate
	and t.CreatedTimestamp < @EndDate

select
	ProductCode 
	,ProductName 
	,convert(varchar(60),CustomerId) as FusebillId
	,isnull(c.firstName,'') as FirstName
	,isnull(c.LastName,'') as LastName
	,convert(varchar(60),ChargeId ) as ChargeId
	,convert(varchar(60),convert(date,r.ChargeDate),107) as ChargeDate
	 ,convert(varchar(60),sum( RevenueCharged )) as RevenueCharged
	  ,convert(varchar(60),sum( DiscountCharged)) as DiscountCharged
	  ,convert(varchar(60),sum(ReversedCharge )) as ReversedCharge
	  ,convert(varchar(60),sum(ReversedDiscount )) as ReversedDiscount
FROM
	@Results
	 r
	 inner join Customer c with (nolock) on r.CustomerId = c.Id 
GROUP BY
	ProductId 
	,ProductCode 
	,GLCodeId 
	,ProductName 
	,CustomerId
	,isnull(c.firstName,'') 
	,isnull(c.LastName,'') 
	,r.ChargeId 
	,r.ChargeDate
set nocount off
	

END

GO

