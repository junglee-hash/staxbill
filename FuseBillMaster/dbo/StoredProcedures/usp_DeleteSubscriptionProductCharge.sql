CREATE PROC [dbo].[usp_DeleteSubscriptionProductCharge]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [SubscriptionProductCharge]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

