CREATE PROC [dbo].[usp_UpdateBillingStatement]

	@Id bigint,
	@CustomerId bigint,
	@StartDate datetime,
	@EndDate datetime,
	@OpeningBalance money,
	@ClosingBalance money,
	@CreatedTimestamp datetime
AS
SET NOCOUNT ON
	UPDATE [BillingStatement] SET 
		[CustomerId] = @CustomerId,
		[StartDate] = @StartDate,
		[EndDate] = @EndDate,
		[OpeningBalance] = @OpeningBalance,
		[ClosingBalance] = @ClosingBalance,
		[CreatedTimestamp] = @CreatedTimestamp
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

