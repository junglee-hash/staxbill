CREATE PROC [dbo].[usp_UpdateCustomerStartingData]

	@Id bigint,
	@OpeningBalance decimal,
	@PreviousLifetimeValue decimal,
	@CreatedTimestamp datetime
AS
SET NOCOUNT ON
	UPDATE [CustomerStartingData] SET 
		[OpeningBalance] = @OpeningBalance,
		[PreviousLifetimeValue] = @PreviousLifetimeValue,
		[CreatedTimestamp] = @CreatedTimestamp
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

