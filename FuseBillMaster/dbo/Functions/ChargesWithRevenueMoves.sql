-- =============================================
-- Author:		Jamie Munro
-- Create date: 2016-09-30
-- Description:	This function returns a list of charge ids that had 
-- earned or deferred revenue moved during the specified date range
-- =============================================
CREATE FUNCTION [dbo].[ChargesWithRevenueMoves]
(	
	@AccountId bigint
	,@StartDate datetime
	,@EndDate datetime -- Expecting end date to be midnight of next day
	,@CurrencyId bigint
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT 
       ChargeId
       ,SUM(EarnedDebit) as EarnedDebitAll
	   ,SUM(EarnedCredit) as EarnedCreditAll
	   ,SUM(DiscountDebit) as DiscountDebitAll
	   ,SUM(DiscountCredit) as DiscountCreditAll
	   ,SUM(UnearnedDebit) as DeferredDebitAll
	   ,SUM(UnearnedCredit) as DeferredCreditAll
	   ,SUM(UnearnedDiscountDebit) as DeferredDiscountDebitAll
	   ,SUM(UnearnedDiscountCredit) as DeferredDiscountCreditAll
	   ,SUM(CASE WHEN InPeriod = 1 THEN EarnedDebit ELSE 0 END) as EarnedDebitInPeriod
	   ,SUM(CASE WHEN InPeriod = 1 THEN EarnedCredit ELSE 0 END) as EarnedCreditInPeriod
	   ,SUM(CASE WHEN InPeriod = 1 THEN DiscountDebit ELSE 0 END) as DiscountDebitInPeriod
	   ,SUM(CASE WHEN InPeriod = 1 THEN DiscountCredit ELSE 0 END) as DiscountCreditInPeriod
	   ,SUM(CASE WHEN InPeriod = 1 THEN UnearnedDebit ELSE 0 END) as DeferredDebitInPeriod
	   ,SUM(CASE WHEN InPeriod = 1 THEN UnearnedCredit ELSE 0 END) as DeferredCreditInPeriod
	   ,SUM(CASE WHEN InPeriod = 1 THEN UnearnedDiscountDebit ELSE 0 END) as DeferredDiscountDebitInPeriod
	   ,SUM(CASE WHEN InPeriod = 1 THEN UnearnedDiscountCredit ELSE 0 END) as DeferredDiscountCreditInPeriod
from
(
-- Get all charges that happened between start and end date
SELECT    
       t.Id as ChargeId
       ,clj.EarnedDebit
	   ,clj.EarnedCredit
	   ,clj.DiscountDebit
	   ,clj.DiscountCredit
	   ,clj.UnearnedDebit
	   ,clj.UnearnedCredit
	   ,clj.UnearnedDiscountDebit
	   ,clj.UnearnedDiscountCredit
	   ,CASE WHEN t.EffectiveTimestamp >= @StartDate THEN 1 ELSE 0 END as InPeriod
FROM         
    dbo.[Transaction] AS t
    INNER JOIN dbo.vw_CustomerLedgerJournal AS clj ON t.Id = clj.TransactionId 
		AND t.AccountId = clj.AccountId
    INNER JOIN Charge ch on t.Id = ch.Id
WHERE     
       t.AccountId = @AccountId
	   AND t.EffectiveTimestamp < @EndDate
       and t.Amount != 0
       AND t.CurrencyId = @CurrencyId

-- Get all earnings that occurred between the start and end date
union all

SELECT    
       ea.ChargeId as ChargeId
       ,clj.EarnedDebit
	   ,clj.EarnedCredit
	   ,clj.DiscountDebit
	   ,clj.DiscountCredit
	   ,clj.UnearnedDebit
	   ,clj.UnearnedCredit
	   ,clj.UnearnedDiscountDebit
	   ,clj.UnearnedDiscountCredit
	   ,CASE WHEN t.EffectiveTimestamp >= @StartDate THEN 1 ELSE 0 END as InPeriod
FROM         
    dbo.[Transaction] AS t
    INNER JOIN dbo.vw_CustomerLedgerJournal AS clj ON t.Id = clj.TransactionId  
		AND t.AccountId = clj.AccountId
    INNER JOIN Earning  ea on t.Id = ea.Id
WHERE     
       t.AccountId = @AccountId
	   AND t.EffectiveTimestamp < @EndDate
       and t.Amount != 0
       AND t.CurrencyId = @CurrencyId

-- Get all reverse charges that happened during the start and end date
union all

SELECT    
       ch.OriginalChargeId  as ChargeId
       ,clj.EarnedDebit
	   ,clj.EarnedCredit
	   ,clj.DiscountDebit
	   ,clj.DiscountCredit
	   ,clj.UnearnedDebit
	   ,clj.UnearnedCredit
	   ,clj.UnearnedDiscountDebit
	   ,clj.UnearnedDiscountCredit
	   ,CASE WHEN t.EffectiveTimestamp >= @StartDate THEN 1 ELSE 0 END as InPeriod
FROM         
    dbo.[Transaction] AS t
    INNER JOIN dbo.vw_CustomerLedgerJournal AS clj ON t.Id = clj.TransactionId  
		AND t.AccountId = clj.AccountId
    INNER JOIN ReverseCharge ch on t.Id = ch.Id
WHERE     
    t.AccountId = @AccountId
	   AND t.EffectiveTimestamp < @EndDate
       and t.Amount != 0
       AND t.CurrencyId = @CurrencyId

-- Get all reverse earnings that occurred during the start and end date
union all

Select 
       rc.OriginalChargeId  as ChargeId
       ,clj.EarnedDebit
	   ,clj.EarnedCredit
	   ,clj.DiscountDebit
	   ,clj.DiscountCredit
	   ,clj.UnearnedDebit
	   ,clj.UnearnedCredit
	   ,clj.UnearnedDiscountDebit
	   ,clj.UnearnedDiscountCredit
	   ,CASE WHEN t.EffectiveTimestamp >= @StartDate THEN 1 ELSE 0 END as InPeriod
from 
    dbo.[Transaction] AS t
	INNER JOIN dbo.vw_CustomerLedgerJournal AS clj ON t.Id = clj.TransactionId  
		AND t.AccountId = clj.AccountId
	INNER JOIN ReverseEarning e on t.Id = e.Id
    INNER JOIN ReverseCharge rc on e.ReverseChargeId = rc.Id 
    INNER JOIN ChargeLastEarning cle on rc.OriginalChargeId = cle.Id
WHERE     
    t.AccountId = @AccountId
	   AND t.EffectiveTimestamp < @EndDate
       and t.Amount != 0
       AND t.CurrencyId = @CurrencyId

-- Get all discount that occurred between start and end date
UNION ALL

Select 
       d.ChargeId  as ChargeId
       ,clj.EarnedDebit
	   ,clj.EarnedCredit
	   ,clj.DiscountDebit
	   ,clj.DiscountCredit
	   ,clj.UnearnedDebit
	   ,clj.UnearnedCredit
	   ,clj.UnearnedDiscountDebit
	   ,clj.UnearnedDiscountCredit
	   ,CASE WHEN t.EffectiveTimestamp >= @StartDate THEN 1 ELSE 0 END as InPeriod
from 
    dbo.[Transaction] AS t
	INNER JOIN dbo.vw_CustomerLedgerJournal AS clj ON t.Id = clj.TransactionId  
		AND t.AccountId = clj.AccountId
	INNER JOIN Discount d ON d.Id = t.Id
WHERE     
    t.AccountId = @AccountId
	   AND t.EffectiveTimestamp < @EndDate
       and t.Amount != 0
       AND t.CurrencyId = @CurrencyId

-- Get all discount earnings that occurred between start and end date
UNION ALL

Select 
       d.ChargeId  as ChargeId
       ,clj.EarnedDebit
	   ,clj.EarnedCredit
	   ,clj.DiscountDebit
	   ,clj.DiscountCredit
	   ,clj.UnearnedDebit
	   ,clj.UnearnedCredit
	   ,clj.UnearnedDiscountDebit
	   ,clj.UnearnedDiscountCredit
	   ,CASE WHEN t.EffectiveTimestamp >= @StartDate THEN 1 ELSE 0 END as InPeriod
from 
    dbo.[Transaction] AS t
	INNER JOIN dbo.vw_CustomerLedgerJournal AS clj ON t.Id = clj.TransactionId  
		AND t.AccountId = clj.AccountId
	INNER JOIN EarningDiscount e on t.Id = e.Id
	INNER JOIN Discount d ON d.Id = e.DiscountId
WHERE     
    t.AccountId = @AccountId
	   AND t.EffectiveTimestamp < @EndDate
       and t.Amount != 0
       AND t.CurrencyId = @CurrencyId

-- Get all reverse discount earnings that occurred between start and end date
UNION ALL

Select 
       d.ChargeId  as ChargeId
       ,clj.EarnedDebit
	   ,clj.EarnedCredit
	   ,clj.DiscountDebit
	   ,clj.DiscountCredit
	   ,clj.UnearnedDebit
	   ,clj.UnearnedCredit
	   ,clj.UnearnedDiscountDebit
	   ,clj.UnearnedDiscountCredit
	   ,CASE WHEN t.EffectiveTimestamp >= @StartDate THEN 1 ELSE 0 END as InPeriod
from 
    dbo.[Transaction] AS t
	INNER JOIN dbo.vw_CustomerLedgerJournal AS clj ON t.Id = clj.TransactionId  
		AND t.AccountId = clj.AccountId
	INNER JOIN ReverseDiscount rd ON t.Id = rd.Id
	INNER JOIN Discount d ON d.Id = rd.OriginalDiscountId
WHERE     
    t.AccountId = @AccountId
	   AND t.EffectiveTimestamp < @EndDate
       and t.Amount != 0
       AND t.CurrencyId = @CurrencyId

-- Get all opening deferred revenue that occurred between start and end date
UNION ALL

SELECT    
       t.Id as ChargeId
       ,clj.EarnedDebit
	   ,clj.EarnedCredit
	   ,clj.DiscountDebit
	   ,clj.DiscountCredit
	   ,clj.UnearnedDebit
	   ,clj.UnearnedCredit
	   ,clj.UnearnedDiscountDebit
	   ,clj.UnearnedDiscountCredit
	   ,CASE WHEN t.EffectiveTimestamp >= @StartDate THEN 1 ELSE 0 END as InPeriod
FROM         
    dbo.[Transaction] AS t
    INNER JOIN dbo.vw_CustomerLedgerJournal AS clj ON t.Id = clj.TransactionId  
		AND t.AccountId = clj.AccountId
    INNER JOIN OpeningDeferredRevenue odr on t.Id = odr.Id
WHERE     
    t.AccountId = @AccountId
	   AND t.EffectiveTimestamp < @EndDate
       and t.Amount != 0
       AND t.CurrencyId = @CurrencyId

-- Get all opening deferred revenue earnings that occurred between start and end date
union all

SELECT    
       ea.OpeningDeferredRevenueId as ChargeId
       ,clj.EarnedDebit
	   ,clj.EarnedCredit
	   ,clj.DiscountDebit
	   ,clj.DiscountCredit
	   ,clj.UnearnedDebit
	   ,clj.UnearnedCredit
	   ,clj.UnearnedDiscountDebit
	   ,clj.UnearnedDiscountCredit
	   ,CASE WHEN t.EffectiveTimestamp >= @StartDate THEN 1 ELSE 0 END as InPeriod
FROM         
    dbo.[Transaction] AS t
	INNER JOIN dbo.vw_CustomerLedgerJournal AS clj ON t.Id = clj.TransactionId  
		AND t.AccountId = clj.AccountId
    INNER JOIN EarningOpeningDeferredRevenue  ea on t.Id = ea.Id
WHERE     
    t.AccountId = @AccountId
	   AND t.EffectiveTimestamp < @EndDate
       and t.Amount != 0
       AND t.CurrencyId = @CurrencyId

)Data
group by ChargeId 
having SUM(CASE WHEN InPeriod = 1 THEN EarnedDebit ELSE 0 END) > 0
	   OR SUM(CASE WHEN InPeriod = 1 THEN EarnedCredit ELSE 0 END) > 0
	   OR SUM(CASE WHEN InPeriod = 1 THEN DiscountDebit ELSE 0 END) > 0
	   OR SUM(CASE WHEN InPeriod = 1 THEN DiscountCredit ELSE 0 END) > 0
	   OR SUM(CASE WHEN InPeriod = 1 THEN UnearnedDebit ELSE 0 END) > 0
	   OR SUM(CASE WHEN InPeriod = 1 THEN UnearnedCredit ELSE 0 END) > 0
	   OR SUM(CASE WHEN InPeriod = 1 THEN UnearnedDiscountDebit ELSE 0 END) > 0
	   OR SUM(CASE WHEN InPeriod = 1 THEN UnearnedDiscountCredit ELSE 0 END) > 0
)

GO

