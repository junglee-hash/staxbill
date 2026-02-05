CREATE PROC [dbo].[usp_DeleteSubscriptionCouponCode]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [SubscriptionCouponCode]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

