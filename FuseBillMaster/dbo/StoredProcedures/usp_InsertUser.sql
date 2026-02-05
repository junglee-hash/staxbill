 
 
CREATE PROC [dbo].[usp_InsertUser]

	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime,
	@Email varchar(255),
	@FirstName nvarchar(500),
	@LastName nvarchar(500)
AS
SET NOCOUNT ON
	INSERT INTO [User] (
		[CreatedTimestamp],
		[ModifiedTimestamp],
		[Email],
		[FirstName],
		[LastName]
	)
	VALUES (
		@CreatedTimestamp,
		@ModifiedTimestamp,
		@Email,
		@FirstName,
		@LastName
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

