 
 
CREATE PROC [dbo].[usp_InsertAccountCurrency]

	@AccountId bigint,
	@CurrencyId bigint,
	@IsDefault bit,
	@CurrencyStatusId int
AS
SET NOCOUNT ON
	INSERT INTO [AccountCurrency] (
		[AccountId],
		[CurrencyId],
		[IsDefault],
		[CurrencyStatusId]
	)
	VALUES (
		@AccountId,
		@CurrencyId,
		@IsDefault,
		@CurrencyStatusId
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

