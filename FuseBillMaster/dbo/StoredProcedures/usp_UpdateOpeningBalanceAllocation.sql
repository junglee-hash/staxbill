CREATE PROC [dbo].[usp_UpdateOpeningBalanceAllocation]

	@Id bigint,
	@OpeningBalanceId bigint,
	@Amount decimal,
	@InvoiceId bigint,
	@EffectiveTimestamp datetime
AS
SET NOCOUNT ON
	UPDATE [OpeningBalanceAllocation] SET 
		[OpeningBalanceId] = @OpeningBalanceId,
		[Amount] = @Amount,
		[InvoiceId] = @InvoiceId,
		[EffectiveTimestamp] = @EffectiveTimestamp
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

