CREATE PROC [dbo].[usp_UpdateSubscriptionProductDiscount]

	@Id bigint,
	@SubscriptionProductId bigint,
	@DiscountTypeId int,
	@Amount decimal,
	@RemainingUsage int,
	@RemainingUsagesUntilStart int,
	@CouponCodeId bigint
AS
SET NOCOUNT ON
	UPDATE [SubscriptionProductDiscount] SET 
		[SubscriptionProductId] = @SubscriptionProductId,
		[DiscountTypeId] = @DiscountTypeId,
		[Amount] = @Amount,
		[RemainingUsage] = @RemainingUsage,
		[RemainingUsagesUntilStart] = @RemainingUsagesUntilStart,
		[CouponCodeId] = @CouponCodeId
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

