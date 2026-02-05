CREATE PROC [dbo].[usp_UpdateTax]

	@Id bigint,
	@InvoiceId bigint,
	@TaxRuleId bigint,
	@ChargeId bigint,
	@RemainingReversalAmount decimal
AS
SET NOCOUNT ON
	UPDATE [Tax] SET 
		[InvoiceId] = @InvoiceId,
		[TaxRuleId] = @TaxRuleId,
		[ChargeId] = @ChargeId,
		[RemainingReversalAmount] = @RemainingReversalAmount
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

