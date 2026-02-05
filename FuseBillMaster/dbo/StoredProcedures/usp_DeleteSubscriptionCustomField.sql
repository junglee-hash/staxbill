CREATE PROC [dbo].[usp_DeleteSubscriptionCustomField]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [SubscriptionCustomField]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

