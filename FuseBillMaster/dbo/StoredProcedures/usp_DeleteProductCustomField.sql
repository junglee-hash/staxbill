CREATE PROC [dbo].[usp_DeleteProductCustomField]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [ProductCustomField]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

