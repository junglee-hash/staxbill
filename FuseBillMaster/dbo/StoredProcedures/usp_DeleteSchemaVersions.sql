CREATE PROC [dbo].[usp_DeleteSchemaVersions]
	@Id int
AS
SET NOCOUNT ON

DELETE FROM [SchemaVersions]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

