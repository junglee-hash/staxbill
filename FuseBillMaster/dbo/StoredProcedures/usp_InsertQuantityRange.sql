 
 
CREATE PROC [dbo].[usp_InsertQuantityRange]

	@Min decimal,
	@Max decimal,
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime,
	@OrderToCashCycleId bigint
AS
SET NOCOUNT ON
	INSERT INTO [QuantityRange] (
		[Min],
		[Max],
		[CreatedTimestamp],
		[ModifiedTimestamp],
		[OrderToCashCycleId]
	)
	VALUES (
		@Min,
		@Max,
		@CreatedTimestamp,
		@ModifiedTimestamp,
		@OrderToCashCycleId
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

