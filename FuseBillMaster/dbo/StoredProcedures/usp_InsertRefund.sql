 
 
CREATE PROC [dbo].[usp_InsertRefund]

	@Id bigint,
	@Reference nvarchar(500),
	@OriginalPaymentId bigint,
	@PaymentActivityJournalId bigint
AS
SET NOCOUNT ON
	INSERT INTO [Refund] (
		[Id],
		[Reference],
		[OriginalPaymentId],
		[PaymentActivityJournalId]
	)
	VALUES (
		@Id,
		@Reference,
		@OriginalPaymentId,
		@PaymentActivityJournalId
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

