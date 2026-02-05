CREATE PROC [dbo].[usp_DeletePurchasePriceRange]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [PurchasePriceRange]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

