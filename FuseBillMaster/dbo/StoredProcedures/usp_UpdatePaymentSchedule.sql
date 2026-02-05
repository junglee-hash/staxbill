CREATE PROC [dbo].[usp_UpdatePaymentSchedule]

	@Id bigint,
	@InvoiceId bigint,
	@Amount money,
	@DaysDueAfterTerm int,
	@CreatedTimestamp datetime,
	@IsDefault bit
AS
SET NOCOUNT ON
	UPDATE [PaymentSchedule] SET 
		[InvoiceId] = @InvoiceId,
		[Amount] = @Amount,
		[DaysDueAfterTerm] = @DaysDueAfterTerm,
		[CreatedTimestamp] = @CreatedTimestamp,
		[IsDefault] = @IsDefault
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

