CREATE PROC [dbo].[usp_UpdateDebitAllocation]

	@Id bigint,
	@DebitId bigint,
	@Amount decimal,
	@InvoiceId bigint,
	@EffectiveTimestamp datetime
AS
SET NOCOUNT ON
	UPDATE [DebitAllocation] SET 
		[DebitId] = @DebitId,
		[Amount] = @Amount,
		[InvoiceId] = @InvoiceId,
		[EffectiveTimestamp] = @EffectiveTimestamp
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

