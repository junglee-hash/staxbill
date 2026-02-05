CREATE PROC [dbo].[usp_DeleteUserAccessLink]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [UserAccessLink]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

