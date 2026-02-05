CREATE PROC [dbo].[usp_UpdateTransaction]

	@Id bigint,
	@CreatedTimestamp datetime,
	@CustomerId bigint,
	@Amount money,
	@EffectiveTimestamp datetime,
	@TransactionTypeId int,
	@Description nvarchar(2000),
	@CurrencyId bigint,
	@SortOrder int
AS
SET NOCOUNT ON
	UPDATE [Transaction] SET 
		[CreatedTimestamp] = @CreatedTimestamp,
		[CustomerId] = @CustomerId,
		[Amount] = @Amount,
		[EffectiveTimestamp] = @EffectiveTimestamp,
		[TransactionTypeId] = @TransactionTypeId,
		[Description] = @Description,
		[CurrencyId] = @CurrencyId,
		[SortOrder] = @SortOrder
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

