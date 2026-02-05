CREATE PROC [dbo].[usp_DeleteAccountUpload]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [AccountUpload]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

