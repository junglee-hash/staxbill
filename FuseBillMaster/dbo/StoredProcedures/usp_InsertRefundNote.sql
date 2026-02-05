 
 
CREATE PROC [dbo].[usp_InsertRefundNote]

	@CreatedTimestamp datetime,
	@Amount money,
	@InvoiceId bigint,
	@RefundId bigint,
	@EffectiveTimestamp datetime
AS
SET NOCOUNT ON
	INSERT INTO [RefundNote] (
		[CreatedTimestamp],
		[Amount],
		[InvoiceId],
		[RefundId],
		[EffectiveTimestamp]
	)
	VALUES (
		@CreatedTimestamp,
		@Amount,
		@InvoiceId,
		@RefundId,
		@EffectiveTimestamp
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

