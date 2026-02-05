Create PROCEDURE [dbo].[usp_UpdateAccountMerchantCardRate]
	@Id as bigint, 
	@AccountId as bigint,
	@ShortCode as varchar(50),
	@Rate as decimal(5,3),
	@FlatRate as decimal(5,3),
	@CreatedTimestamp as datetime,
	@ModifiedTimestamp as datetime
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE [AccountMerchantCardRate] SET
		ModifiedTimestamp = @ModifiedTimestamp,
		CreatedTimestamp = @CreatedTimestamp,
		ShortCode = @ShortCode,
		Rate = @Rate,
		FlatRate = @FlatRate,
		AccountId = @AccountId
	WHERE Id = @Id
END

GO

