CREATE PROC [dbo].[usp_UpdateDraftTax]

	@Id bigint,
	@TaxRuleId bigint,
	@DraftInvoiceId bigint,
	@DraftChargeId bigint,
	@Amount money,
	@CurrencyId bigint
AS
SET NOCOUNT ON
	UPDATE [DraftTax] SET 
		[TaxRuleId] = @TaxRuleId,
		[DraftInvoiceId] = @DraftInvoiceId,
		[DraftChargeId] = @DraftChargeId,
		[Amount] = @Amount,
		[CurrencyId] = @CurrencyId
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

