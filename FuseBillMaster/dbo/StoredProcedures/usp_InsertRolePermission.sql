 
 
CREATE PROC [dbo].[usp_InsertRolePermission]

	@RoleId bigint,
	@PermissionId bigint,
	@ParentId bigint,
	@SortOrder int,
	@Allowed bit
AS
SET NOCOUNT ON
	INSERT INTO [RolePermission] (
		[RoleId],
		[PermissionId],
		[ParentId],
		[SortOrder],
		[Allowed]
	)
	VALUES (
		@RoleId,
		@PermissionId,
		@ParentId,
		@SortOrder,
		@Allowed
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

