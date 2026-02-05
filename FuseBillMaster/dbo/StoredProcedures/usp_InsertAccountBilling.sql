 
 
CREATE PROC [dbo].[usp_InsertAccountBilling]

	@AccountId bigint,
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime,
	@CompletedTimestamp datetime,
	@TotalCustomers int,
	@CustomersBilled int
AS
SET NOCOUNT ON
	INSERT INTO [AccountBilling] (
		[AccountId],
		[CreatedTimestamp],
		[ModifiedTimestamp],
		[CompletedTimestamp],
		[TotalCustomers],
		[CustomersBilled]
	)
	VALUES (
		@AccountId,
		@CreatedTimestamp,
		@ModifiedTimestamp,
		@CompletedTimestamp,
		@TotalCustomers,
		@CustomersBilled
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

