CREATE PROC [dbo].[usp_UpdateCouponPlanProduct]

	@Id bigint,
	@CouponPlanId bigint,
	@PlanProductKey bigint,
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime
AS
SET NOCOUNT ON
	UPDATE [CouponPlanProduct] SET 
		[CouponPlanId] = @CouponPlanId,
		[PlanProductKey] = @PlanProductKey,
		[CreatedTimestamp] = @CreatedTimestamp,
		[ModifiedTimestamp] = @ModifiedTimestamp
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

