Create PROCEDURE [dbo].[usp_InsertAccountMerchantCardRate]
	@AccountId as bigint,
	@ShortCode as varchar(50),
	@Rate as decimal(5,3),
	@FlatRate as decimal(5,3),
	@CreatedTimestamp as datetime,
	@ModifiedTimestamp as datetime
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO [AccountMerchantCardRate] (
		CreatedTimestamp
		, ModifiedTimestamp
		, ShortCode
		, Rate
		, FlatRate
		, AccountId
	) VALUES (
		@CreatedTimestamp
		, @ModifiedTimestamp
		, @ShortCode
		, @Rate
		, @FlatRate
		, @AccountId)
	
	SELECT @@IDENTITY as Id
END

GO

