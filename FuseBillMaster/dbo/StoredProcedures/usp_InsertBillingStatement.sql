CREATE PROC [dbo].[usp_InsertBillingStatement]

	@CustomerId bigint,
	@StartDate datetime,
	@EndDate datetime,
	@OpeningBalance money,
	@ClosingBalance money,
	@CreatedTimestamp datetime,
	@StatementActivityType int,
	@StatementOption int
AS
SET NOCOUNT ON
	INSERT INTO [BillingStatement] (
		[CustomerId],
		[StartDate],
		[EndDate],
		[OpeningBalance],
		[ClosingBalance],
		[CreatedTimestamp],
		[StatementActivityTypeId],
		[StatementOptionId]
	)
	VALUES (
		@CustomerId,
		@StartDate,
		@EndDate,
		@OpeningBalance,
		@ClosingBalance,
		@CreatedTimestamp,
		@StatementActivityType,
		@StatementOption
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

