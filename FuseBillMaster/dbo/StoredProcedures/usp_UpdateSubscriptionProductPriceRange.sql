CREATE PROC [dbo].[usp_UpdateSubscriptionProductPriceRange]

	@Id bigint,
	@SubscriptionProductId bigint,
	@Min decimal,
	@Max decimal,
	@Amount decimal
AS
SET NOCOUNT ON
	UPDATE [SubscriptionProductPriceRange] SET 
		[SubscriptionProductId] = @SubscriptionProductId,
		[Min] = @Min,
		[Max] = @Max,
		[Amount] = @Amount
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

