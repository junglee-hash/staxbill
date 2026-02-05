CREATE PROC [dbo].[usp_UpdatePayment]

	@Id bigint,
	@Reference nvarchar(500),
	@PaymentActivityJournalId bigint,
	@RefundableAmount decimal,
	@UnallocatedAmount decimal,
	@GatewayFee decimal(18,6)
AS
SET NOCOUNT ON
	UPDATE [Payment] SET 
		[Reference] = @Reference,
		[PaymentActivityJournalId] = @PaymentActivityJournalId,
		[RefundableAmount] = @RefundableAmount,
		[UnallocatedAmount] = @UnallocatedAmount,
		[GatewayFee] = @GatewayFee
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

