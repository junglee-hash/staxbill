-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetSubscriptionsWithoutPlanProduct]
	@SubscriptionIds varchar(max),
	@PlanProductId bigint,
	@AccountId bigint
AS
BEGIN
	SELECT s.Id FROM Subscription s
	INNER JOIN (SELECT * FROM dbo.Split(@SubscriptionIds, '|')) as pIds ON CAST(pIds.Data as bigint) = s.Id
	INNER JOIN Customer c ON c.Id = s.CustomerId
	LEFT JOIN SubscriptionProduct sp ON s.Id = sp.SubscriptionId AND sp.PlanProductId = @PlanProductId
	WHERE c.AccountId = @AccountId
	AND sp.Id IS NULL
	AND s.IsDeleted = 0
END

GO

