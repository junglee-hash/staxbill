 
 
CREATE PROC [dbo].[usp_InsertDebitAllocation]

	@DebitId bigint,
	@Amount decimal,
	@InvoiceId bigint,
	@EffectiveTimestamp datetime
AS
SET NOCOUNT ON
	INSERT INTO [DebitAllocation] (
		[DebitId],
		[Amount],
		[InvoiceId],
		[EffectiveTimestamp]
	)
	VALUES (
		@DebitId,
		@Amount,
		@InvoiceId,
		@EffectiveTimestamp
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

