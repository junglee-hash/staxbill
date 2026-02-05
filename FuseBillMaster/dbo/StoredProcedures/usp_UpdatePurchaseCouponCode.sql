CREATE PROC [dbo].[usp_UpdatePurchaseCouponCode]

	@Id bigint,
	@PurchaseId bigint,
	@CouponCodeId bigint,
	@CreatedTimestamp datetime
AS
SET NOCOUNT ON
	UPDATE [PurchaseCouponCode] SET 
		[PurchaseId] = @PurchaseId,
		[CouponCodeId] = @CouponCodeId,
		[CreatedTimestamp] = @CreatedTimestamp
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

