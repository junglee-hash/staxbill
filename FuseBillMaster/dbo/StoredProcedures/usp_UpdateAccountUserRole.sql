CREATE PROC [dbo].[usp_UpdateAccountUserRole]

	@Id bigint,
	@RoleTypeId int,
	@AccountUserId bigint,
	@RoleId bigint,
	@SalesTrackingCodeId bigint = null
AS
SET NOCOUNT ON
	UPDATE [AccountUserRole] SET 
		[RoleTypeId] = @RoleTypeId,
		[AccountUserId] = @AccountUserId,
		[RoleId] = @RoleId,
		[SalesTrackingCodeId] = @SalesTrackingCodeId
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

