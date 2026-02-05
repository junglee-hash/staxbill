 
 
CREATE PROC [dbo].[usp_InsertPaymentSchedule]

	@InvoiceId bigint,
	@Amount money,
	@DaysDueAfterTerm int,
	@CreatedTimestamp datetime,
	@IsDefault bit
AS
SET NOCOUNT ON
	INSERT INTO [PaymentSchedule] (
		[InvoiceId],
		[Amount],
		[DaysDueAfterTerm],
		[CreatedTimestamp],
		[IsDefault]
	)
	VALUES (
		@InvoiceId,
		@Amount,
		@DaysDueAfterTerm,
		@CreatedTimestamp,
		@IsDefault
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

