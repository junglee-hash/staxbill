CREATE PROC [dbo].[usp_UpdateCreditCardExpiryActivity]

	@Id bigint,
	@MonthNotice int,
	@CreatedTimestamp datetime,
	@CreditCardId bigint
AS
SET NOCOUNT ON
	UPDATE [CreditCardExpiryActivity] SET 
		[MonthNotice] = @MonthNotice,
		[CreatedTimestamp] = @CreatedTimestamp,
		[CreditCardId] = @CreditCardId
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

