 
 
CREATE PROC [dbo].[usp_InsertSubscriptionCouponCode]

	@SubscriptionId bigint,
	@CouponCodeId bigint,
	@CreatedTimestamp datetime,
	@StatusId int,
	@DeletedTimestamp datetime
AS
SET NOCOUNT ON
	INSERT INTO [SubscriptionCouponCode] (
		[SubscriptionId],
		[CouponCodeId],
		[CreatedTimestamp],
		[StatusId],
		[DeletedTimestamp]
	)
	VALUES (
		@SubscriptionId,
		@CouponCodeId,
		@CreatedTimestamp,
		@StatusId,
		@DeletedTimestamp
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

