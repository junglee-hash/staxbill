
CREATE PROCEDURE [dbo].[Staffside_BillingByAccount]
	@StartDate DATETIME
	,@EndDate DATETIME
AS

SET TRANSACTION ISOLATION LEVEL SNAPSHOT

SELECT
	a.Id as AccountId
	,a.CompanyName
	,at.Name as Type
	,a.Live
	,SUM(ab.CustomersBilled) as CustomersBilled
	,SUM(DATEDIFF(SECOND,ab.CreatedTimestamp,ISNULL(ab.CompletedTimestamp,GETUTCDATE()))) as 'BillingTimeConsumed(s)'
FROM AccountBilling ab
INNER JOIN Account a ON a.Id = ab.AccountId
INNER JOIN Lookup.AccountType at ON at.Id = a.TypeId
WHERE ab.CreatedTimestamp >= @StartDate
	AND ab.CreatedTimestamp < @EndDate
GROUP BY
	a.Id
	,a.CompanyName
	,a.Live
	,at.Name
ORDER BY [BillingTimeConsumed(s)] DESC

GO

