CREATE PROC [dbo].[usp_DeleteSubscriptionProductDiscount]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [SubscriptionProductDiscount]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

