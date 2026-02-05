CREATE PROC [dbo].[usp_UpdatePurchaseProductItem]

	@PurchaseId bigint,
	@Id bigint
AS
SET NOCOUNT ON
	UPDATE [PurchaseProductItem] SET 
		[Id] = @Id
	WHERE [PurchaseId] = @PurchaseId

SET NOCOUNT OFF

GO

