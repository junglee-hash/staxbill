
CREATE PROCEDURE [dbo].[Staffside_CustomerLedgerJournalTroubleshooter]
	 @CustomerId BIGINT
	,@StartDate DATETIME
	,@EndDate DATETIME
AS 

SELECT
	tt.Name as TransactionType
	,t.EffectiveTimestamp
	,clj.*
FROM [Transaction] t (NOLOCK)
INNER JOIN vw_CustomerLedgerJournal clj (NOLOCK) ON t.Id = clj.TransactionId
INNER JOIN Lookup.TransactionType tt (NOLOCK) ON tt.Id = t.TransactionTypeId
WHERE t.CustomerId = @CustomerId
	AND t.EffectiveTimestamp >= @StartDate
	AND t.EffectiveTimestamp < @EndDate
ORDER BY t.EffectiveTimestamp

GO

