CREATE PROC [dbo].[usp_DeleteAccountUser]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [AccountUser]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

