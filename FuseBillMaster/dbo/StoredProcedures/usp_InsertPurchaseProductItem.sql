 
 
CREATE PROC [dbo].[usp_InsertPurchaseProductItem]

	@PurchaseId bigint,
	@Id bigint
AS
SET NOCOUNT ON
	INSERT INTO [PurchaseProductItem] (
		[PurchaseId],
		[Id]
	)
	VALUES (
		@PurchaseId,
		@Id
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

