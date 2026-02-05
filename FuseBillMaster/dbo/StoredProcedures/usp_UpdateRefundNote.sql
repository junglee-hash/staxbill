CREATE PROC [dbo].[usp_UpdateRefundNote]

	@Id bigint,
	@CreatedTimestamp datetime,
	@Amount money,
	@InvoiceId bigint,
	@RefundId bigint,
	@EffectiveTimestamp datetime
AS
SET NOCOUNT ON
	UPDATE [RefundNote] SET 
		[CreatedTimestamp] = @CreatedTimestamp,
		[Amount] = @Amount,
		[InvoiceId] = @InvoiceId,
		[RefundId] = @RefundId,
		[EffectiveTimestamp] = @EffectiveTimestamp
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

