CREATE PROC [dbo].[usp_DeleteGrandfatheringSubscriptionChangeLog]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [GrandfatheringSubscriptionChangeLog]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

