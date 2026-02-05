 
 
CREATE PROC [dbo].[usp_InsertPaymentNote]

	@CreatedTimestamp datetime,
	@Amount money,
	@InvoiceId bigint,
	@PaymentId bigint,
	@EffectiveTimestamp datetime
AS
SET NOCOUNT ON
	INSERT INTO [PaymentNote] (
		[CreatedTimestamp],
		[Amount],
		[InvoiceId],
		[PaymentId],
		[EffectiveTimestamp]
	)
	VALUES (
		@CreatedTimestamp,
		@Amount,
		@InvoiceId,
		@PaymentId,
		@EffectiveTimestamp
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

