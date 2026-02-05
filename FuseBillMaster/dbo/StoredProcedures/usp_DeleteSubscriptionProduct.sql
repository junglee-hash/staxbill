CREATE PROC [dbo].[usp_DeleteSubscriptionProduct]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [SubscriptionProduct]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

