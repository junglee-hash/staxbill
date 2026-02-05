CREATE PROC [dbo].[usp_DeleteUser]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [User]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

