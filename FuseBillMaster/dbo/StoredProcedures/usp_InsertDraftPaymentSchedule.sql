 
 
CREATE PROC [dbo].[usp_InsertDraftPaymentSchedule]

	@DraftInvoiceId bigint,
	@Amount money,
	@DaysDueAfterTerm int,
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime
AS
SET NOCOUNT ON
	INSERT INTO [DraftPaymentSchedule] (
		[DraftInvoiceId],
		[Amount],
		[DaysDueAfterTerm],
		[CreatedTimestamp],
		[ModifiedTimestamp]
	)
	VALUES (
		@DraftInvoiceId,
		@Amount,
		@DaysDueAfterTerm,
		@CreatedTimestamp,
		@ModifiedTimestamp
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

