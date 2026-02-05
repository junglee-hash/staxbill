
CREATE PROCEDURE [dbo].[Staffside_EarningByAccount]
	@StartDate DATETIME
	,@EndDate DATETIME
AS

SET TRANSACTION ISOLATION LEVEL SNAPSHOT

SELECT
	a.Id as AccountId
	,a.CompanyName
	,at.Name as Type
	,a.Live
	,SUM(ab.RecordsCreated) as FinancialsCreated
	,SUM(DATEDIFF(SECOND,ab.StartTimestamp,ISNULL(ab.CompletedTimestamp,GETUTCDATE()))) as 'EarningTimeConsumed(s)'
FROM AccountEarning ab
INNER JOIN Account a ON a.Id = ab.AccountId
INNER JOIN Lookup.AccountType at ON at.Id = a.TypeId
WHERE ab.CreatedTimestamp >= @StartDate
	AND ab.CreatedTimestamp < @EndDate
GROUP BY
	a.Id
	,a.CompanyName
	,a.Live
	,at.Name
ORDER BY [EarningTimeConsumed(s)] DESC

GO

