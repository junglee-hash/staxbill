
CREATE FUNCTION [dbo].[tvf_TransactionLedgers]
(@AccountId BIGINT
,@CurrencyId BIGINT
,@StartDate DATETIME = NULL
,@EndDate DATETIME
)

RETURNS TABLE
AS
RETURN

SELECT
	t.Id AS TransactionId
	,t.TransactionTypeId
	,t.CustomerId
	,t.AccountId
	,t.CurrencyId
	,t.EffectiveTimestamp
	,t.Amount
	,t.Description
	,CASE WHEN LedgerTypeId =  1 AND EntryType = 'Debit' THEN Amount ELSE 0 END AS ArDebit
	,CASE WHEN LedgerTypeId =  1 AND EntryType = 'Credit' THEN Amount ELSE 0 END AS ArCredit
	,CASE WHEN LedgerTypeId =  2 AND EntryType = 'Debit' THEN Amount ELSE 0 END AS CashDebit
	,CASE WHEN LedgerTypeId =  2 AND EntryType = 'Credit' THEN Amount ELSE 0 END AS CashCredit
	,CASE WHEN LedgerTypeId =  4 AND EntryType = 'Debit' THEN Amount ELSE 0 END AS UnearnedDebit
	,CASE WHEN LedgerTypeId =  4 AND EntryType = 'Credit' THEN Amount ELSE 0 END AS UnearnedCredit
	,CASE WHEN LedgerTypeId =  3 AND EntryType = 'Debit' THEN Amount ELSE 0 END AS EarnedDebit
	,CASE WHEN LedgerTypeId =  3 AND EntryType = 'Credit' THEN Amount ELSE 0 END AS EarnedCredit
	,CASE WHEN LedgerTypeId =  7 AND EntryType = 'Debit' THEN Amount ELSE 0 END AS WriteOffDebit
	,CASE WHEN LedgerTypeId =  7 AND EntryType = 'Credit' THEN Amount ELSE 0 END AS WriteOffCredit
	,CASE WHEN LedgerTypeId =  5 AND EntryType = 'Debit' THEN Amount ELSE 0 END AS TaxesPayableDebit
	,CASE WHEN LedgerTypeId =  5 AND EntryType = 'Credit' THEN Amount ELSE 0 END AS TaxesPayableCredit
	,CASE WHEN LedgerTypeId =  6 AND EntryType = 'Debit' THEN Amount ELSE 0 END AS DiscountDebit
	,CASE WHEN LedgerTypeId =  6 AND EntryType = 'Credit' THEN Amount ELSE 0 END AS DiscountCredit
	,CASE WHEN LedgerTypeId =  8 AND EntryType = 'Debit' THEN Amount ELSE 0 END AS OpeningBalanceDebit
	,CASE WHEN LedgerTypeId =  8 AND EntryType = 'Credit' THEN Amount ELSE 0 END AS OpeningBalanceCredit
	,CASE WHEN LedgerTypeId =  9 AND EntryType = 'Debit' THEN Amount ELSE 0 END AS CreditDebit
	,CASE WHEN LedgerTypeId =  9 AND EntryType = 'Credit' THEN Amount ELSE 0 END AS CreditCredit
	,CASE WHEN LedgerTypeId =  10 AND EntryType = 'Debit' THEN Amount ELSE 0 END AS UnearnedDiscountDebit
	,CASE WHEN LedgerTypeId =  10 AND EntryType = 'Credit' THEN Amount ELSE 0 END AS UnearnedDiscountCredit
	,CASE WHEN LedgerTypeId =  11 AND EntryType = 'Debit' THEN Amount ELSE 0 END AS OpeningDeferredRevenueDebit
	,CASE WHEN LedgerTypeId =  11 AND EntryType = 'Credit' THEN Amount ELSE 0 END AS OpeningDeferredRevenueCredit
	--,LedgerTypeId
FROM [Transaction] t
INNER JOIN Lookup.TransactionTypeLedger lttl ON lttl.TransactionTypeId = t.TransactionTypeId
--INNER JOIN Lookup.[LedgerType] llt ON llt.Id = lttl.LedgerTypeId
WHERE t.Amount <> 0
AND AccountId = @AccountId
AND CurrencyId = @CurrencyId
--AND (LedgerTypeId = @LedgerTypeId OR @LedgerTypeId IS NULL)
AND (t.EffectiveTimestamp >= @StartDate OR @StartDate IS NULL)
AND t.EffectiveTimestamp < @EndDate

GO

