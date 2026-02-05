CREATE PROC [dbo].[usp_DeleteSubscriptionProductOverride]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [SubscriptionProductOverride]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

