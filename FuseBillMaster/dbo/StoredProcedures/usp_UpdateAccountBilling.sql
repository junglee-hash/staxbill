CREATE PROC [dbo].[usp_UpdateAccountBilling]

	@Id bigint,
	@AccountId bigint,
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime,
	@CompletedTimestamp datetime,
	@TotalCustomers int,
	@CustomersBilled int,
	@ThreadName nvarchar(255),
	@ThreadsInUse int
AS
SET NOCOUNT ON
	UPDATE [AccountBilling] SET 
		[AccountId] = @AccountId,
		[CreatedTimestamp] = @CreatedTimestamp,
		[ModifiedTimestamp] = @ModifiedTimestamp,
		[CompletedTimestamp] = @CompletedTimestamp,
		[TotalCustomers] = @TotalCustomers,
		[CustomersBilled] = @CustomersBilled,
		[ThreadName] = @ThreadName,
		[ThreadsInUse] = @ThreadsInUse
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

