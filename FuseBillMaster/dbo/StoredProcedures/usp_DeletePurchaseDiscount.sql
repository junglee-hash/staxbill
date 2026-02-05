CREATE PROC [dbo].[usp_DeletePurchaseDiscount]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [PurchaseDiscount]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

