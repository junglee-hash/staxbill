 
 
CREATE PROC [dbo].[usp_InsertOpeningBalanceAllocation]

	@OpeningBalanceId bigint,
	@Amount decimal,
	@InvoiceId bigint,
	@EffectiveTimestamp datetime
AS
SET NOCOUNT ON
	INSERT INTO [OpeningBalanceAllocation] (
		[OpeningBalanceId],
		[Amount],
		[InvoiceId],
		[EffectiveTimestamp]
	)
	VALUES (
		@OpeningBalanceId,
		@Amount,
		@InvoiceId,
		@EffectiveTimestamp
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

