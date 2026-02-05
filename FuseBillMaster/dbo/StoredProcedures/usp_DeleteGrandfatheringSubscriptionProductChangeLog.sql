CREATE PROC [dbo].[usp_DeleteGrandfatheringSubscriptionProductChangeLog]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [GrandfatheringSubscriptionProductChangeLog]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

