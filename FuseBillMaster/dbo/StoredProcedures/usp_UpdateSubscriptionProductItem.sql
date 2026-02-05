CREATE PROC [dbo].[usp_UpdateSubscriptionProductItem]

	@SubscriptionProductId bigint,
	@Id bigint
AS
SET NOCOUNT ON
	UPDATE [SubscriptionProductItem] SET 
		[Id] = @Id
	WHERE [SubscriptionProductId] = @SubscriptionProductId

SET NOCOUNT OFF

GO

