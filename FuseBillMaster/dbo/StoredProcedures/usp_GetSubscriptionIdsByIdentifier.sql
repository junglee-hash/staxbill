CREATE   PROCEDURE [dbo].[usp_GetSubscriptionIdsByIdentifier]
@AccountId BIGINT,
@Reference NVARCHAR(255) = NULL,
@Name NVARCHAR(100) = NULL,
@Description NVARCHAR(500) = NULL
/*
	note that the purpose of this sproc is to find a single subscription,
	therefore it does not consult a subscription's default name and description (i.e. s.PlanName or s.PlanDescription)
*/
WITH RECOMPILE
AS

SET NOCOUNT ON


SELECT s.Id
	FROM dbo.Subscription s 
	LEFT JOIN dbo.SubscriptionOverride so ON s.Id = so.Id
WHERE s.StatusId in (2,4,6) --active, provisioning, suspended
	AND s.AccountId =  @AccountId
	AND (
			(s.Reference = @Reference AND @Reference IS NOT NULL)
			OR (so.[Name] = @Name AND @Name IS NOT NULL)
			OR (so.[Description] = @Description AND @Description IS NOT NULL)
		)	

SET NOCOUNT OFF

GO

