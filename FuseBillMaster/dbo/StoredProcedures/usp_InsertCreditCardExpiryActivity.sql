 
 
CREATE PROC [dbo].[usp_InsertCreditCardExpiryActivity]

	@MonthNotice int,
	@CreatedTimestamp datetime,
	@CreditCardId bigint
AS
SET NOCOUNT ON
	INSERT INTO [CreditCardExpiryActivity] (
		[MonthNotice],
		[CreatedTimestamp],
		[CreditCardId]
	)
	VALUES (
		@MonthNotice,
		@CreatedTimestamp,
		@CreditCardId
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

