CREATE PROC [dbo].[usp_DeleteRolePermission]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [RolePermission]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

