 
 
CREATE PROC [dbo].[usp_InsertSchemaVersions]

	@ScriptName nvarchar(255),
	@Applied datetime
AS
SET NOCOUNT ON
	INSERT INTO [SchemaVersions] (
		[ScriptName],
		[Applied]
	)
	VALUES (
		@ScriptName,
		@Applied
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

