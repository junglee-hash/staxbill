 
 
CREATE PROC [dbo].[usp_InsertCouponDiscount]

	@CouponId bigint,
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime,
	@DiscountConfigurationId bigint,
	@CouponEligibilityId bigint
AS
SET NOCOUNT ON
	INSERT INTO [CouponDiscount] (
		[CouponId],
		[CreatedTimestamp],
		[ModifiedTimestamp],
		[DiscountConfigurationId],
		[CouponEligibilityId]
	)
	VALUES (
		@CouponId,
		@CreatedTimestamp,
		@ModifiedTimestamp,
		@DiscountConfigurationId,
		@CouponEligibilityId
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

