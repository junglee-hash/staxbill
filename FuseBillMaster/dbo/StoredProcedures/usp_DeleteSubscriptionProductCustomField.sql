CREATE PROC [dbo].[usp_DeleteSubscriptionProductCustomField]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [SubscriptionProductCustomField]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

