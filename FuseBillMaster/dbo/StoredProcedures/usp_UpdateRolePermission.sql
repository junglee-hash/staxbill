CREATE PROC [dbo].[usp_UpdateRolePermission]

	@Id bigint,
	@RoleId bigint,
	@PermissionId bigint,
	@ParentId bigint,
	@SortOrder int,
	@Allowed bit
AS
SET NOCOUNT ON
	UPDATE [RolePermission] SET 
		[RoleId] = @RoleId,
		[PermissionId] = @PermissionId,
		[ParentId] = @ParentId,
		[SortOrder] = @SortOrder,
		[Allowed] = @Allowed
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

