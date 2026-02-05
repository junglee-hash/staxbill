CREATE FUNCTION [dbo].[tvf_CustomerLedgers]
(@AccountId BIGINT
,@CurrencyId BIGINT
,@StartDate DATETIME = NULL
,@EndDate DATETIME
,@CustomerIds IDList READONLY
)

RETURNS TABLE
AS
RETURN

SELECT
	CustomerId
	,SUM(CASE WHEN LedgerTypeId =  1 AND EntryType = 'Debit' THEN Amount ELSE 0 END) AS ArDebit
	,SUM(CASE WHEN LedgerTypeId =  1 AND EntryType = 'Credit' THEN Amount ELSE 0 END) AS ArCredit
	,SUM(CASE WHEN LedgerTypeId =  2 AND EntryType = 'Debit' THEN Amount ELSE 0 END) AS CashDebit
	,SUM(CASE WHEN LedgerTypeId =  2 AND EntryType = 'Credit' THEN Amount ELSE 0 END) AS CashCredit
	,SUM(CASE WHEN LedgerTypeId =  4 AND EntryType = 'Debit' THEN Amount ELSE 0 END) AS UnearnedDebit
	,SUM(CASE WHEN LedgerTypeId =  4 AND EntryType = 'Credit' THEN Amount ELSE 0 END) AS UnearnedCredit
	,SUM(CASE WHEN LedgerTypeId =  3 AND EntryType = 'Debit' THEN Amount ELSE 0 END) AS EarnedDebit
	,SUM(CASE WHEN LedgerTypeId =  3 AND EntryType = 'Credit' THEN Amount ELSE 0 END) AS EarnedCredit
	,SUM(CASE WHEN LedgerTypeId =  7 AND EntryType = 'Debit' THEN Amount ELSE 0 END) AS WriteOffDebit
	,SUM(CASE WHEN LedgerTypeId =  7 AND EntryType = 'Credit' THEN Amount ELSE 0 END) AS WriteOffCredit
	,SUM(CASE WHEN LedgerTypeId =  5 AND EntryType = 'Debit' THEN Amount ELSE 0 END) AS TaxesPayableDebit
	,SUM(CASE WHEN LedgerTypeId =  5 AND EntryType = 'Credit' THEN Amount ELSE 0 END) AS TaxesPayableCredit
	,SUM(CASE WHEN LedgerTypeId =  6 AND EntryType = 'Debit' THEN Amount ELSE 0 END) AS DiscountDebit
	,SUM(CASE WHEN LedgerTypeId =  6 AND EntryType = 'Credit' THEN Amount ELSE 0 END) AS DiscountCredit
	,SUM(CASE WHEN LedgerTypeId =  8 AND EntryType = 'Debit' THEN Amount ELSE 0 END) AS OpeningBalanceDebit
	,SUM(CASE WHEN LedgerTypeId =  8 AND EntryType = 'Credit' THEN Amount ELSE 0 END) AS OpeningBalanceCredit
	,SUM(CASE WHEN LedgerTypeId =  9 AND EntryType = 'Debit' THEN Amount ELSE 0 END) AS CreditDebit
	,SUM(CASE WHEN LedgerTypeId =  9 AND EntryType = 'Credit' THEN Amount ELSE 0 END) AS CreditCredit
	,SUM(CASE WHEN LedgerTypeId =  10 AND EntryType = 'Debit' THEN Amount ELSE 0 END) AS UnearnedDiscountDebit
	,SUM(CASE WHEN LedgerTypeId =  10 AND EntryType = 'Credit' THEN Amount ELSE 0 END) AS UnearnedDiscountCredit
	,SUM(CASE WHEN LedgerTypeId =  11 AND EntryType = 'Debit' THEN Amount ELSE 0 END) AS OpeningDeferredRevenueDebit
	,SUM(CASE WHEN LedgerTypeId =  11 AND EntryType = 'Credit' THEN Amount ELSE 0 END) AS OpeningDeferredRevenueCredit
	--,LedgerTypeId
FROM [Transaction] t
INNER JOIN Lookup.TransactionTypeLedger lttl ON lttl.TransactionTypeId = t.TransactionTypeId
--INNER JOIN Lookup.[LedgerType] llt ON llt.Id = lttl.LedgerTypeId
INNER JOIN @CustomerIds c ON c.Id = t.CustomerId
WHERE t.Amount <> 0
AND AccountId = @AccountId
AND CurrencyId = @CurrencyId
--AND (LedgerTypeId = @LedgerTypeId OR @LedgerTypeId IS NULL)
AND (t.EffectiveTimestamp >= @StartDate OR @StartDate IS NULL)
AND t.EffectiveTimestamp < @EndDate
GROUP BY 
CustomerId

GO

