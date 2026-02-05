 
 
CREATE PROC [dbo].[usp_InsertDraftTax]

	@TaxRuleId bigint,
	@DraftInvoiceId bigint,
	@DraftChargeId bigint,
	@Amount money,
	@CurrencyId bigint
AS
SET NOCOUNT ON
	INSERT INTO [DraftTax] (
		[TaxRuleId],
		[DraftInvoiceId],
		[DraftChargeId],
		[Amount],
		[CurrencyId]
	)
	VALUES (
		@TaxRuleId,
		@DraftInvoiceId,
		@DraftChargeId,
		@Amount,
		@CurrencyId
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

