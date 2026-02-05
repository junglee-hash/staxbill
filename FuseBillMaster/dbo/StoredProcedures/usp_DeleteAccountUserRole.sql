CREATE PROC [dbo].[usp_DeleteAccountUserRole]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [AccountUserRole]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

