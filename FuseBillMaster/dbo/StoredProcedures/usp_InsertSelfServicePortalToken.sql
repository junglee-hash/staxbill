 
 
CREATE PROC [dbo].[usp_InsertSelfServicePortalToken]

	@Token uniqueidentifier,
	@CustomerId bigint,
	@CreatedTimestamp datetime,
	@IsConsumed bit,
	@TokenTypeID int
AS
SET NOCOUNT ON
	INSERT INTO [SelfServicePortalToken] (
		[Token],
		[CustomerId],
		[CreatedTimestamp],
		[IsConsumed],
		[TokenTypeID]
	)
	VALUES (
		@Token,
		@CustomerId,
		@CreatedTimestamp,
		@IsConsumed,
		@TokenTypeID
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

