 
 
CREATE PROC [dbo].[usp_InsertPurchaseDiscount]

	@PurchaseId bigint,
	@DiscountTypeId int,
	@Amount decimal,
	@CouponCodeId bigint
AS
SET NOCOUNT ON
	INSERT INTO [PurchaseDiscount] (
		[PurchaseId],
		[DiscountTypeId],
		[Amount],
		[CouponCodeId]
	)
	VALUES (
		@PurchaseId,
		@DiscountTypeId,
		@Amount,
		@CouponCodeId
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

