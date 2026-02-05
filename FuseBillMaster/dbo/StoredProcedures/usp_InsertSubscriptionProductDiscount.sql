 
 
CREATE PROC [dbo].[usp_InsertSubscriptionProductDiscount]

	@SubscriptionProductId bigint,
	@DiscountTypeId int,
	@Amount decimal,
	@RemainingUsage int,
	@RemainingUsagesUntilStart int,
	@CouponCodeId bigint
AS
SET NOCOUNT ON
	INSERT INTO [SubscriptionProductDiscount] (
		[SubscriptionProductId],
		[DiscountTypeId],
		[Amount],
		[RemainingUsage],
		[RemainingUsagesUntilStart],
		[CouponCodeId]
	)
	VALUES (
		@SubscriptionProductId,
		@DiscountTypeId,
		@Amount,
		@RemainingUsage,
		@RemainingUsagesUntilStart,
		@CouponCodeId
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

