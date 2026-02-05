CREATE PROC [dbo].[usp_DeleteAccountApiKey]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [AccountApiKey]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

