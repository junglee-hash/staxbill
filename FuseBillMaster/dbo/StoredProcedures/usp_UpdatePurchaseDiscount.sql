CREATE PROC [dbo].[usp_UpdatePurchaseDiscount]

	@Id bigint,
	@PurchaseId bigint,
	@DiscountTypeId int,
	@Amount decimal,
	@CouponCodeId bigint
AS
SET NOCOUNT ON
	UPDATE [PurchaseDiscount] SET 
		[PurchaseId] = @PurchaseId,
		[DiscountTypeId] = @DiscountTypeId,
		[Amount] = @Amount,
		[CouponCodeId] = @CouponCodeId
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

