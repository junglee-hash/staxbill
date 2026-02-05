 
 
CREATE PROC [dbo].[usp_InsertPurchasePriceRange]

	@PurchaseId bigint,
	@Min decimal,
	@Max decimal,
	@Amount decimal
AS
SET NOCOUNT ON
	INSERT INTO [PurchasePriceRange] (
		[PurchaseId],
		[Min],
		[Max],
		[Amount]
	)
	VALUES (
		@PurchaseId,
		@Min,
		@Max,
		@Amount
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

