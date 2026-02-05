CREATE PROC [dbo].[usp_UpdateFusebillSupportUser]

	@Id bigint,
	@ActiveDirectoryUsername nvarchar(255),
	@UserId bigint
AS
SET NOCOUNT ON
	UPDATE [FusebillSupportUser] SET 
		[ActiveDirectoryUsername] = @ActiveDirectoryUsername,
		[UserId] = @UserId
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

