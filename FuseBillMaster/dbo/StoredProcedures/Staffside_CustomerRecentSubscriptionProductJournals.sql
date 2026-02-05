

CREATE   PROCEDURE [dbo].[Staffside_CustomerRecentSubscriptionProductJournals]
 @CustomerId BIGINT 
 ,@StartDate DATETIME 
 ,@EndDate DATETIME
AS

SELECT
	spj.*
	,s.CustomerId as StaxBillId
	,sp.SubscriptionId
	,s.PlanName
	,sp.PlanProductName
	,sp.PlanProductId
FROM SubscriptionProductJournal spj (NOLOCK)
INNER JOIN SubscriptionProduct sp (NOLOCK) ON sp.Id = spj.SubscriptionProductId
INNER JOIN Subscription s (NOLOCK) ON s.Id = sp.SubscriptionId
WHERE S.CustomerId = @CustomerId
	AND spj.CreatedTimestamp >= @StartDate
	AND spj.CreatedTimestamp < @EndDate
ORDER BY spj.Id DESC

GO

