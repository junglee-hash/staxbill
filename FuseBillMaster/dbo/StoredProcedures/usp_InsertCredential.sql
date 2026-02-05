 
 
CREATE PROC [dbo].[usp_InsertCredential]

	@UserId bigint,
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime,
	@Username nvarchar(255),
	@Password nvarchar(255),
	@Salt varchar(1000)
AS
SET NOCOUNT ON
	INSERT INTO [Credential] (
		[UserId],
		[CreatedTimestamp],
		[ModifiedTimestamp],
		[Username],
		[Password],
		[Salt]
	)
	VALUES (
		@UserId,
		@CreatedTimestamp,
		@ModifiedTimestamp,
		@Username,
		@Password,
		@Salt
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

