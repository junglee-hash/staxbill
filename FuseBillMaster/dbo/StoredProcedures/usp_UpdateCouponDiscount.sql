CREATE PROC [dbo].[usp_UpdateCouponDiscount]

	@Id bigint,
	@CouponId bigint,
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime,
	@DiscountConfigurationId bigint,
	@CouponEligibilityId bigint
AS
SET NOCOUNT ON
	UPDATE [CouponDiscount] SET 
		[CouponId] = @CouponId,
		[CreatedTimestamp] = @CreatedTimestamp,
		[ModifiedTimestamp] = @ModifiedTimestamp,
		[DiscountConfigurationId] = @DiscountConfigurationId,
		[CouponEligibilityId] = @CouponEligibilityId
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

