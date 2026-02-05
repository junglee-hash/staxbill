 
 
CREATE PROC [dbo].[usp_InsertCouponPlan]

	@CouponId bigint,
	@PlanId bigint,
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime,
	@ApplyToAllProducts bit
AS
SET NOCOUNT ON
	INSERT INTO [CouponPlan] (
		[CouponId],
		[PlanId],
		[CreatedTimestamp],
		[ModifiedTimestamp],
		[ApplyToAllProducts]
	)
	VALUES (
		@CouponId,
		@PlanId,
		@CreatedTimestamp,
		@ModifiedTimestamp,
		@ApplyToAllProducts
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

