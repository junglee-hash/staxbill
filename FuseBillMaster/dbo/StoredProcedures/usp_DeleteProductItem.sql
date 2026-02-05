CREATE PROC [dbo].[usp_DeleteProductItem]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [ProductItem]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

