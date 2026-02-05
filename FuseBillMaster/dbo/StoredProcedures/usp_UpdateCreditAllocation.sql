CREATE PROC [dbo].[usp_UpdateCreditAllocation]

	@Id bigint,
	@CreditId bigint,
	@Amount decimal,
	@InvoiceId bigint,
	@EffectiveTimestamp datetime
AS
SET NOCOUNT ON
	UPDATE [CreditAllocation] SET 
		[CreditId] = @CreditId,
		[Amount] = @Amount,
		[InvoiceId] = @InvoiceId,
		[EffectiveTimestamp] = @EffectiveTimestamp
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

