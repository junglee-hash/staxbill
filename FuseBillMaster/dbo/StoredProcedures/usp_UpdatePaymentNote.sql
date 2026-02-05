CREATE PROC [dbo].[usp_UpdatePaymentNote]

	@Id bigint,
	@CreatedTimestamp datetime,
	@Amount money,
	@InvoiceId bigint,
	@PaymentId bigint,
	@EffectiveTimestamp datetime
AS
SET NOCOUNT ON
	UPDATE [PaymentNote] SET 
		[CreatedTimestamp] = @CreatedTimestamp,
		[Amount] = @Amount,
		[InvoiceId] = @InvoiceId,
		[PaymentId] = @PaymentId,
		[EffectiveTimestamp] = @EffectiveTimestamp
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

