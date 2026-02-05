 
 
CREATE PROC [dbo].[usp_InsertCustomerEmailControl]

	@CustomerId bigint,
	@EmailKey varchar(50),
	@CreatedTimestamp datetime
AS
SET NOCOUNT ON
	INSERT INTO [CustomerEmailControl] (
		[CustomerId],
		[EmailKey],
		[CreatedTimestamp]
	)
	VALUES (
		@CustomerId,
		@EmailKey,
		@CreatedTimestamp
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

