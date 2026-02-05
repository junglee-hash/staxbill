CREATE PROC [dbo].[usp_UpdateUser]

	@Id bigint,
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime,
	@Email varchar(255),
	@FirstName nvarchar(500),
	@LastName nvarchar(500)
AS
SET NOCOUNT ON
	UPDATE [User] SET 
		[CreatedTimestamp] = @CreatedTimestamp,
		[ModifiedTimestamp] = @ModifiedTimestamp,
		[Email] = @Email,
		[FirstName] = @FirstName,
		[LastName] = @LastName
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

