
CREATE PROCEDURE [dbo].[usp_GetSubscriptionsWithoutPlanProductCount]
	@subscriptionIds AS dbo.IDList READONLY,
	@planProductId bigint,
	@accountId bigint
AS
BEGIN
	SELECT COUNT(s.Id)
	FROM Subscription s
		INNER JOIN @subscriptionIds subIds ON s.Id = subIds.Id
		INNER JOIN Customer c ON c.Id = s.CustomerId
		LEFT JOIN SubscriptionProduct sp ON
			s.Id = sp.SubscriptionId AND
			sp.PlanProductId = @PlanProductId
	WHERE
		c.AccountId = @accountId AND
		sp.Id IS NULL AND
		s.IsDeleted = 0
END

GO

