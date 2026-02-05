 
 
CREATE PROC [dbo].[usp_InsertCouponCode]

	@CouponId bigint,
	@Code varchar(255),
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime,
	@AccountId bigint,
	@TimesUsed int,
	@RemainingUsages int
AS
SET NOCOUNT ON
	INSERT INTO [CouponCode] (
		[CouponId],
		[Code],
		[CreatedTimestamp],
		[ModifiedTimestamp],
		[AccountId],
		[TimesUsed],
		[RemainingUsages]
	)
	VALUES (
		@CouponId,
		@Code,
		@CreatedTimestamp,
		@ModifiedTimestamp,
		@AccountId,
		@TimesUsed,
		@RemainingUsages
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

