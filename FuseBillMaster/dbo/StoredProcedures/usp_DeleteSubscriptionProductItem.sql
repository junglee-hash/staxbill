CREATE PROC [dbo].[usp_DeleteSubscriptionProductItem]
	@SubscriptionProductId bigint
AS
SET NOCOUNT ON

DELETE FROM [SubscriptionProductItem]
WHERE [SubscriptionProductId] = @SubscriptionProductId

SET NOCOUNT OFF

GO

