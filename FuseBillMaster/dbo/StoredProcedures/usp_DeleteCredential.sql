CREATE PROC [dbo].[usp_DeleteCredential]
	@UserId bigint
AS
SET NOCOUNT ON

DELETE FROM [Credential]
WHERE [UserId] = @UserId

SET NOCOUNT OFF

GO

