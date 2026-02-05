 
 
CREATE PROC [dbo].[usp_InsertCouponPlanProduct]

	@CouponPlanId bigint,
	@PlanProductKey bigint,
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime
AS
SET NOCOUNT ON
	INSERT INTO [CouponPlanProduct] (
		[CouponPlanId],
		[PlanProductKey],
		[CreatedTimestamp],
		[ModifiedTimestamp]
	)
	VALUES (
		@CouponPlanId,
		@PlanProductKey,
		@CreatedTimestamp,
		@ModifiedTimestamp
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

