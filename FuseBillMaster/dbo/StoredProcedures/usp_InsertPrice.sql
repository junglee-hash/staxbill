 
 
CREATE PROC [dbo].[usp_InsertPrice]

	@QuantityRangeId bigint,
	@Amount decimal,
	@CurrencyId bigint
AS
SET NOCOUNT ON
	INSERT INTO [Price] (
		[QuantityRangeId],
		[Amount],
		[CurrencyId]
	)
	VALUES (
		@QuantityRangeId,
		@Amount,
		@CurrencyId
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

