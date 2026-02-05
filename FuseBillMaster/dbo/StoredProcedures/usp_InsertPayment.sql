CREATE PROC [dbo].[usp_InsertPayment]

	@Id bigint,
	@Reference nvarchar(500),
	@PaymentActivityJournalId bigint,
	@RefundableAmount decimal,
	@UnallocatedAmount decimal,
	@GatewayFee decimal(18,6)
AS
SET NOCOUNT ON
	INSERT INTO [Payment] (
		[Id],
		[Reference],
		[PaymentActivityJournalId],
		[RefundableAmount],
		[UnallocatedAmount],
		[GatewayFee]
	)
	VALUES (
		@Id,
		@Reference,
		@PaymentActivityJournalId,
		@RefundableAmount,
		@UnallocatedAmount,
		@GatewayFee
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

