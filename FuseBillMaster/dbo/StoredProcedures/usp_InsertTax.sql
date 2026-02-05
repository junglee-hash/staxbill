 
 
CREATE PROC [dbo].[usp_InsertTax]

	@Id bigint,
	@InvoiceId bigint,
	@TaxRuleId bigint,
	@ChargeId bigint,
	@RemainingReversalAmount decimal
AS
SET NOCOUNT ON
	INSERT INTO [Tax] (
		[Id],
		[InvoiceId],
		[TaxRuleId],
		[ChargeId],
		[RemainingReversalAmount]
	)
	VALUES (
		@Id,
		@InvoiceId,
		@TaxRuleId,
		@ChargeId,
		@RemainingReversalAmount
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

