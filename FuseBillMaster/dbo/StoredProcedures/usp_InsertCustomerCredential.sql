 
 
CREATE PROC [dbo].[usp_InsertCustomerCredential]

	@Id bigint,
	@Username nvarchar(50),
	@Password varchar(255),
	@Salt varchar(255),
	@AccountId bigint,
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime
AS
SET NOCOUNT ON
	INSERT INTO [CustomerCredential] (
		[Id],
		[Username],
		[Password],
		[Salt],
		[AccountId],
		[CreatedTimestamp],
		[ModifiedTimestamp]
	)
	VALUES (
		@Id,
		@Username,
		@Password,
		@Salt,
		@AccountId,
		@CreatedTimestamp,
		@ModifiedTimestamp
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

