 
 
CREATE PROC [dbo].[usp_InsertPurchaseCouponCode]

	@PurchaseId bigint,
	@CouponCodeId bigint,
	@CreatedTimestamp datetime
AS
SET NOCOUNT ON
	INSERT INTO [PurchaseCouponCode] (
		[PurchaseId],
		[CouponCodeId],
		[CreatedTimestamp]
	)
	VALUES (
		@PurchaseId,
		@CouponCodeId,
		@CreatedTimestamp
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

