 
 
CREATE PROC [dbo].[usp_InsertCustomerStartingData]

	@Id bigint,
	@OpeningBalance decimal,
	@PreviousLifetimeValue decimal,
	@CreatedTimestamp datetime
AS
SET NOCOUNT ON
	INSERT INTO [CustomerStartingData] (
		[Id],
		[OpeningBalance],
		[PreviousLifetimeValue],
		[CreatedTimestamp]
	)
	VALUES (
		@Id,
		@OpeningBalance,
		@PreviousLifetimeValue,
		@CreatedTimestamp
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

