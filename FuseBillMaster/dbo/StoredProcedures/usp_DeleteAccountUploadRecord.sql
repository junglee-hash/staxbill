CREATE PROC [dbo].[usp_DeleteAccountUploadRecord]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [AccountUploadRecord]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

