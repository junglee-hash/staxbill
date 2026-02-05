CREATE PROC [dbo].[usp_UpdateCredential]

	@UserId bigint,
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime,
	@Username nvarchar(255),
	@Password nvarchar(255),
	@Salt varchar(1000)
AS
SET NOCOUNT ON
	UPDATE [Credential] SET 
		[CreatedTimestamp] = @CreatedTimestamp,
		[ModifiedTimestamp] = @ModifiedTimestamp,
		[Username] = @Username,
		[Password] = @Password,
		[Salt] = @Salt
	WHERE [UserId] = @UserId

SET NOCOUNT OFF

GO

