

CREATE   PROCEDURE [dbo].[Staffside_CustomerRecentSubscriptionProductActivityJournals]
 @CustomerId BIGINT 
 ,@StartDate DATETIME 
 ,@EndDate DATETIME
 AS
 BEGIN

SET TRANSACTION ISOLATION LEVEL SNAPSHOT

SELECT
	s.CustomerId AS StaxBillId
	,spaj.*
	,sp.PlanProductName
	,sp.PlanProductCode
	,sp.Id AS SubscriptionProductId
	,sp.SubscriptionId AS SubscriptionId
	,s.PlanName
	,s.PlanCode
FROM SubscriptionProductActivityJournal spaj
INNER JOIN SubscriptionProduct sp ON sp.Id = spaj.SubscriptionProductId
INNER JOIN Subscription s ON s.Id = sp.SubscriptionId
WHERE s.CustomerId = @CustomerId
	AND spaj.CreatedTimestamp >= @StartDate
	AND spaj.CreatedTimestamp < @EndDate
END

GO

