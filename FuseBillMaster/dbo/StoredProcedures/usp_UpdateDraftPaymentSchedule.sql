CREATE PROC [dbo].[usp_UpdateDraftPaymentSchedule]

	@Id bigint,
	@DraftInvoiceId bigint,
	@Amount money,
	@DaysDueAfterTerm int,
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime
AS
SET NOCOUNT ON
	UPDATE [DraftPaymentSchedule] SET 
		[DraftInvoiceId] = @DraftInvoiceId,
		[Amount] = @Amount,
		[DaysDueAfterTerm] = @DaysDueAfterTerm,
		[CreatedTimestamp] = @CreatedTimestamp,
		[ModifiedTimestamp] = @ModifiedTimestamp
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

