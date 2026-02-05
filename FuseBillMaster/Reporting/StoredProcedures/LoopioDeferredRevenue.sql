
CREATE PROCEDURE [Reporting].[LoopioDeferredRevenue]
@AccountId bigint 
,@StartDate DATETIME
,@EndDate DATETIME
AS

/*TESTING
DECLARE
@AccountId BIGINT = 10
,@StartDate DATETIME
,@EndDate DATETIME
--*/

SET TRANSACTION ISOLATION LEVEL SNAPSHOT

----------------------
--NOTES ON THIS BLOCK
--There are two oddities in the source stored procedure
----*In the case where the StartDate is NULL resulting in the UTC conversion of a UTC datetime. 
----*CurrencyId is hardcoded as 1 even in the case where an AccountId has other currencies
--Both are understood but we want to minimise the chance of the result set being changed by addressing either

DECLARE @ReportDateTime DATETIME = @StartDate
,@CurrencyId BIGINT = 1 

IF @ReportDateTime IS NULL
    SET @ReportDateTime = GETUTCDATE()

DECLARE @TimezoneId int

SELECT @TimezoneId = TimezoneId
	,@ReportDateTime = dbo.fn_GetUtcTime(@ReportDateTime,TimezoneId)
FROM AccountPreference where Id = @AccountId 

----------------------
--NOTES ON THIS BLOCK
--No effort has been made to optimise or improve logic in this section, it simply replaces the LedgerEntry join with comparable logic to TransactionTypeLedger for the translation (see story #23007)

create table #ResultTable
(
ChargeId bigint primary Key
,DataAmount money
,ReversedAmount money
)
insert into #ResultTable 
SELECT 
       ChargeId
       ,sum(Amount) as DataAmount 
       ,sum(case when Reversed = 1 then Amount else 0 end) as ReversedAmount
from
(
SELECT    
       t.Id as ChargeId
       --,ISNULL( le.Credit,0)- ISNULL( le.Debit,0) as Amount
	   ,(CASE WHEN ttl.EntryType = 'Credit' THEN COALESCE(Amount,0) ELSE 0 END - CASE WHEN ttl.EntryType = 'Debit' THEN COALESCE(Amount,0) ELSE 0 END) AS Amount
       ,0 as Reversed
FROM         
       dbo.Customer AS c 
       INNER JOIN dbo.[Transaction] AS t ON c.Id = t.CustomerId 
       INNER JOIN Lookup.TransactionTypeLedger ttl ON ttl.TransactionTypeId = t.TransactionTypeId
       inner join Charge ch on t.Id = ch.Id
WHERE     
       ttl.LedgerTypeId = 4
       AND c.AccountId = @AccountId
       AND t.EffectiveTimestamp < @ReportDateTime
       and t.Amount != 0
       AND t.CurrencyId = @CurrencyId

union all

SELECT    
       ea.ChargeId as ChargeId
       --,ISNULL( le.Credit,0)- ISNULL( le.Debit,0) as Amount
	   ,(CASE WHEN ttl.EntryType = 'Credit' THEN COALESCE(Amount,0) ELSE 0 END - CASE WHEN ttl.EntryType = 'Debit' THEN COALESCE(Amount,0) ELSE 0 END) AS Amount
       ,0 as Reversed
FROM         
       dbo.Customer AS c 
       INNER JOIN dbo.[Transaction] AS t ON c.Id = t.CustomerId 
       INNER JOIN Lookup.TransactionTypeLedger ttl ON ttl.TransactionTypeId = t.TransactionTypeId
       inner join Earning  ea on t.Id = ea.Id
WHERE     
       ttl.LedgerTypeId = 4
       AND c.AccountId = @AccountId
       AND t.EffectiveTimestamp < @ReportDateTime
       and t.Amount != 0
       AND t.CurrencyId = @CurrencyId

union all

SELECT    
       ch.OriginalChargeId  as ChargeId
       --,ISNULL( le.Credit,0)- ISNULL( le.Debit,0) as Amount
	   ,(CASE WHEN ttl.EntryType = 'Credit' THEN COALESCE(Amount,0) ELSE 0 END - CASE WHEN ttl.EntryType = 'Debit' THEN COALESCE(Amount,0) ELSE 0 END) AS Amount
       ,1 as Reversed
FROM         
       dbo.Customer AS c 
       INNER JOIN dbo.[Transaction] AS t ON c.Id = t.CustomerId 
       INNER JOIN Lookup.TransactionTypeLedger ttl ON ttl.TransactionTypeId = t.TransactionTypeId
       inner join ReverseCharge ch on t.Id = ch.Id
WHERE     
       ttl.LedgerTypeId = 4
       AND c.AccountId = @AccountId
       AND t.EffectiveTimestamp < @ReportDateTime
       and t.Amount != 0
       AND t.CurrencyId = @CurrencyId

union all

Select 
       rc.OriginalChargeId  as ChargeId
       ,(CASE WHEN ttl.EntryType = 'Credit' THEN COALESCE(Amount,0) ELSE 0 END - CASE WHEN ttl.EntryType = 'Debit' THEN COALESCE(Amount,0) ELSE 0 END) AS Amount
       ,0 as Reversed
from 
       Customer c
       inner join dbo.[Transaction] AS t ON c.Id = t.CustomerId 
	   INNER JOIN Lookup.TransactionTypeLedger ttl ON ttl.TransactionTypeId = t.TransactionTypeId
       inner join ReverseEarning e
       on t.Id = e.Id
       inner join ReverseCharge rc
       on e.ReverseChargeId = rc.Id 
       inner join ChargeLastEarning cle
       on rc.OriginalChargeId = cle.Id
WHERE     
       ttl.LedgerTypeId = 4
       AND c.AccountId = @AccountId
       AND t.EffectiveTimestamp < @ReportDateTime
       and t.Amount != 0
       AND t.CurrencyId = @CurrencyId

UNION ALL

SELECT    
       t.Id as ChargeId
       --,ISNULL( le.Credit,0)- ISNULL( le.Debit,0) as Amount
	   ,(CASE WHEN ttl.EntryType = 'Credit' THEN COALESCE(Amount,0) ELSE 0 END - CASE WHEN ttl.EntryType = 'Debit' THEN COALESCE(Amount,0) ELSE 0 END) AS Amount
       ,0 as Reversed
FROM         
       dbo.Customer AS c 
       INNER JOIN dbo.[Transaction] AS t ON c.Id = t.CustomerId 
       INNER JOIN Lookup.TransactionTypeLedger ttl ON ttl.TransactionTypeId = t.TransactionTypeId
       inner join OpeningDeferredRevenue odr on t.Id = odr.Id
WHERE     
       ttl.LedgerTypeId = 4
       AND c.AccountId = @AccountId
       AND t.EffectiveTimestamp < @ReportDateTime
       and t.Amount != 0
       AND t.CurrencyId = @CurrencyId

union all

SELECT    
       ea.OpeningDeferredRevenueId as ChargeId
      --,ISNULL( le.Credit,0)- ISNULL( le.Debit,0) as Amount
	   ,(CASE WHEN ttl.EntryType = 'Credit' THEN COALESCE(Amount,0) ELSE 0 END - CASE WHEN ttl.EntryType = 'Debit' THEN COALESCE(Amount,0) ELSE 0 END) AS Amount
       ,0 as Reversed
FROM         
       dbo.Customer AS c 
       INNER JOIN dbo.[Transaction] AS t ON c.Id = t.CustomerId 
       INNER JOIN Lookup.TransactionTypeLedger ttl ON ttl.TransactionTypeId = t.TransactionTypeId
       inner join EarningOpeningDeferredRevenue  ea on t.Id = ea.Id
WHERE     
       ttl.LedgerTypeId = 4
       AND c.AccountId = @AccountId
       AND t.EffectiveTimestamp < @ReportDateTime
       and t.Amount != 0
       AND t.CurrencyId = @CurrencyId

)Data
group by ChargeId 
having
       sum(Amount) !=0



Select * from
(
SELECT
       c.Id as [Fusebill ID]
	   ,c.Reference as [Customer ID]
	   ,c.FirstName as [Customer First Name]
	   ,c.LastName as [Customer Last Name]
	   ,c.CompanyName as [Customer Company Name]
       ,convert(date,dbo.fn_GetTimezoneTime(t.EffectiveTimestamp ,@TimezoneId )) as [Original Transaction Date]
       ,t.Id as [Transaction ID]
       ,isnull(convert(nvarchar,s.Id),'') as [Subscription ID]
       ,isnull(s.PlanName,'') as [Subscription Name]
       ,isnull(convert(nvarchar,pu.Id),'') as [Purchase ID]
       ,coalesce(convert(nvarchar,sp.ProductId), convert(nvarchar,pro.Id),'') as [Product ID]
       ,coalesce(sp.PlanProductName, pro.Name,'') as [Product Name]
	   ,isnull(gl.Code,'') as [GL Code]
       ,t.Amount  - isnull(ReversedAmount,0)      as [Total Charge Amount]
       ,dataAmount as [Unearned Revenue]
       ,convert(date,dbo.fn_GetTimezoneTime(COALESCE(ch.EarningStartDate,odr.EarningStartDate),@TimezoneId )) as [Earning Start Date]
       ,convert(date,dbo.fn_GetTimezoneTime(COALESCE(ch.EarningEndDate, odr.EarningEndDate),@TimezoneId )) as [Earning End Date]
	   ,tt.Name as [Transaction Type]
	   ,t.Description as [Transaction Description]
	   ,COALESCE(ch.Name,tt.Name) as [Transaction Name]
from
       #ResultTable ad
left join Charge ch on ad.ChargeId = ch.Id
left join OpeningDeferredRevenue odr on ad.ChargeId = odr.Id
inner join [Transaction] t on ISNULL(ch.Id,odr.Id) = t.Id 
inner join Lookup.TransactionType tt on tt.Id = t.TransactionTypeId
       left join SubscriptionProductCharge spc 
       on spc.Id = ch.Id
       left join SubscriptionProduct sp
       on spc.SubscriptionProductId = sp.Id
       left join Subscription s
       on sp.SubscriptionId = s.Id
       left join PurchaseCharge pc on ch.Id = pc.Id 
       left join Purchase pu on pc.PurchaseId = pu.Id 
       left join Product pro on pu.ProductId = pro.Id
	   left join GLCode gl on gl.Id = ch.GLCodeId
	   INNER JOIN Customer c ON c.Id = t.CustomerId
) Result
Where [Unearned Revenue] !=0
Order by [Fusebill ID]

drop table #ResultTable

GO

