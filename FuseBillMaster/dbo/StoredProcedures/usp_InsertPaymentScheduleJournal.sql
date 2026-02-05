 
 
CREATE PROC [dbo].[usp_InsertPaymentScheduleJournal]

	@PaymentScheduleId bigint,
	@DueDate datetime,
	@StatusId int,
	@OutstandingBalance money,
	@CreatedTimestamp datetime,
	@IsActive bit
AS
SET NOCOUNT ON
	INSERT INTO [PaymentScheduleJournal] (
		[PaymentScheduleId],
		[DueDate],
		[StatusId],
		[OutstandingBalance],
		[CreatedTimestamp],
		[IsActive]
	)
	VALUES (
		@PaymentScheduleId,
		@DueDate,
		@StatusId,
		@OutstandingBalance,
		@CreatedTimestamp,
		@IsActive
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

