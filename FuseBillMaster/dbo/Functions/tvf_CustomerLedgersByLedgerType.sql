
CREATE FUNCTION [dbo].[tvf_CustomerLedgersByLedgerType]
(@AccountId BIGINT
,@CurrencyId BIGINT
,@StartDate DATETIME = NULL
,@EndDate DATETIME
,@LedgerTypeId BIGINT = NULL
)

--Input parameter for LedgerTypeId (NULL (default) returns ALL)

--SELECT * FROM Lookup.LedgerType

--Id	Name
--1		AR balance
--2		Cash collected
--3		Earned revenue
--4		Deferred revenue
--5		Taxes payable
--6		Discount
--7		Write off
--8		Opening balance
--9		Credit
--10	Deferred discount
--11	Opening deferred revenue balan

RETURNS TABLE
AS
RETURN

SELECT
	t.CustomerId
	,llt.[Name] AS LedgerType
	,SUM(CASE WHEN lttl.EntryType = 'Debit' THEN Amount ELSE 0 END) AS SumDebit
	,SUM(CASE WHEN lttl.EntryType = 'Credit' THEN Amount ELSE 0 END) AS SumCredit
FROM [Transaction] t
INNER JOIN Lookup.TransactionTypeLedger lttl ON lttl.TransactionTypeId = t.TransactionTypeId
INNER JOIN Lookup.[LedgerType] llt ON llt.Id = lttl.LedgerTypeId
WHERE t.Amount <> 0
AND AccountId = @AccountId
AND CurrencyId = @CurrencyId
AND (LedgerTypeId = @LedgerTypeId OR @LedgerTypeId IS NULL)
AND (t.EffectiveTimestamp >= @StartDate OR @StartDate IS NULL)
AND t.EffectiveTimestamp < @EndDate
GROUP BY 
CustomerId
,llt.[Name]

GO

