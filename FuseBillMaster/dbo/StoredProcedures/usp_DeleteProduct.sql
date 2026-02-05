CREATE PROC [dbo].[usp_DeleteProduct]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [Product]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

