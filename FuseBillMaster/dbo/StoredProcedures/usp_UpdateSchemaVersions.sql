CREATE PROC [dbo].[usp_UpdateSchemaVersions]

	@Id int,
	@ScriptName nvarchar(255),
	@Applied datetime
AS
SET NOCOUNT ON
	UPDATE [SchemaVersions] SET 
		[ScriptName] = @ScriptName,
		[Applied] = @Applied
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

