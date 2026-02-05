CREATE PROC [dbo].[usp_DeleteSubscriptionOverride]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [SubscriptionOverride]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

