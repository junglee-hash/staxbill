CREATE PROC [dbo].[usp_UpdateSubscriptionCouponCode]

	@Id bigint,
	@SubscriptionId bigint,
	@CouponCodeId bigint,
	@CreatedTimestamp datetime,
	@StatusId int,
	@DeletedTimestamp datetime
AS
SET NOCOUNT ON
	UPDATE [SubscriptionCouponCode] SET 
		[SubscriptionId] = @SubscriptionId,
		[CouponCodeId] = @CouponCodeId,
		[CreatedTimestamp] = @CreatedTimestamp,
		[StatusId] = @StatusId,
		[DeletedTimestamp] = @DeletedTimestamp
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

