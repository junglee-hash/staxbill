 
 
CREATE PROC [dbo].[usp_InsertCustomerNote]

	@CustomerId bigint,
	@UserId bigint,
	@Note varchar(2000),
	@CreatedTimestamp datetime
AS
SET NOCOUNT ON
	INSERT INTO [CustomerNote] (
		[CustomerId],
		[UserId],
		[Note],
		[CreatedTimestamp]
	)
	VALUES (
		@CustomerId,
		@UserId,
		@Note,
		@CreatedTimestamp
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

