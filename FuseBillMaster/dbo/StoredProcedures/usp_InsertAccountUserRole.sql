CREATE PROC [dbo].[usp_InsertAccountUserRole]

	@RoleTypeId int,
	@AccountUserId bigint,
	@RoleId bigint,
	@SalesTrackingCodeId bigint = null
AS
SET NOCOUNT ON
	INSERT INTO [AccountUserRole] (
		[RoleTypeId],
		[AccountUserId],
		[RoleId],
		[SalesTrackingCodeId]
	)
	VALUES (
		@RoleTypeId,
		@AccountUserId,
		@RoleId,
		@SalesTrackingCodeId
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

