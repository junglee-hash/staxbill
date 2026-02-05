CREATE PROC [dbo].[usp_UpdateAccountCurrency]

	@Id bigint,
	@AccountId bigint,
	@CurrencyId bigint,
	@IsDefault bit,
	@CurrencyStatusId int
AS
SET NOCOUNT ON
	UPDATE [AccountCurrency] SET 
		[AccountId] = @AccountId,
		[CurrencyId] = @CurrencyId,
		[IsDefault] = @IsDefault,
		[CurrencyStatusId] = @CurrencyStatusId
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

