CREATE PROC [dbo].[usp_UpdatePaymentScheduleJournal]

	@Id bigint,
	@PaymentScheduleId bigint,
	@DueDate datetime,
	@StatusId int,
	@OutstandingBalance money,
	@CreatedTimestamp datetime,
	@IsActive bit
AS
SET NOCOUNT ON
	UPDATE [PaymentScheduleJournal] SET 
		[PaymentScheduleId] = @PaymentScheduleId,
		[DueDate] = @DueDate,
		[StatusId] = @StatusId,
		[OutstandingBalance] = @OutstandingBalance,
		[CreatedTimestamp] = @CreatedTimestamp,
		[IsActive] = @IsActive
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

