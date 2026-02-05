CREATE PROC [dbo].[usp_DeletePurchaseProductItem]
	@PurchaseId bigint
AS
SET NOCOUNT ON

DELETE FROM [PurchaseProductItem]
WHERE [PurchaseId] = @PurchaseId

SET NOCOUNT OFF

GO

