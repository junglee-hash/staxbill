CREATE PROC [dbo].[usp_UpdateCouponCode]

	@Id bigint,
	@CouponId bigint,
	@Code varchar(255),
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime,
	@AccountId bigint,
	@TimesUsed int,
	@RemainingUsages int
AS
SET NOCOUNT ON
	UPDATE [CouponCode] SET 
		[CouponId] = @CouponId,
		[Code] = @Code,
		[CreatedTimestamp] = @CreatedTimestamp,
		[ModifiedTimestamp] = @ModifiedTimestamp,
		[AccountId] = @AccountId,
		[TimesUsed] = @TimesUsed,
		[RemainingUsages] = @RemainingUsages
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

