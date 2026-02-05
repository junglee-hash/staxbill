 
 
CREATE PROC [dbo].[usp_InsertCreditAllocation]

	@CreditId bigint,
	@Amount decimal,
	@InvoiceId bigint,
	@EffectiveTimestamp datetime
AS
SET NOCOUNT ON
	INSERT INTO [CreditAllocation] (
		[CreditId],
		[Amount],
		[InvoiceId],
		[EffectiveTimestamp]
	)
	VALUES (
		@CreditId,
		@Amount,
		@InvoiceId,
		@EffectiveTimestamp
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

