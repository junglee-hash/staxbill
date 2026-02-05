CREATE PROC [dbo].[usp_UpdateCouponPlan]

	@Id bigint,
	@CouponId bigint,
	@PlanId bigint,
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime,
	@ApplyToAllProducts bit
AS
SET NOCOUNT ON
	UPDATE [CouponPlan] SET 
		[CouponId] = @CouponId,
		[PlanId] = @PlanId,
		[CreatedTimestamp] = @CreatedTimestamp,
		[ModifiedTimestamp] = @ModifiedTimestamp,
		[ApplyToAllProducts] = @ApplyToAllProducts
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

