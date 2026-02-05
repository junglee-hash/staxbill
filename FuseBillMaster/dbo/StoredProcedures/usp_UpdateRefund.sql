CREATE PROC [dbo].[usp_UpdateRefund]

	@Id bigint,
	@Reference nvarchar(500),
	@OriginalPaymentId bigint,
	@PaymentActivityJournalId bigint
AS
SET NOCOUNT ON
	UPDATE [Refund] SET 
		[Reference] = @Reference,
		[OriginalPaymentId] = @OriginalPaymentId,
		[PaymentActivityJournalId] = @PaymentActivityJournalId
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

