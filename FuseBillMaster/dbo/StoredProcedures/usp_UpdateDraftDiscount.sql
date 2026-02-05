CREATE PROC [dbo].[usp_UpdateDraftDiscount]

	@Id bigint,
	@ConfiguredDiscountAmount decimal,
	@Amount decimal,
	@DraftChargeId bigint,
	@DiscountTypeId int,
	@CreatedTimestamp datetime,
	@EffectiveTimestamp datetime,
	@TransactionTypeId int,
	@Description nvarchar(2000),
	@CurrencyId bigint,
	@Quantity decimal
AS
SET NOCOUNT ON
	UPDATE [DraftDiscount] SET 
		[ConfiguredDiscountAmount] = @ConfiguredDiscountAmount,
		[Amount] = @Amount,
		[DraftChargeId] = @DraftChargeId,
		[DiscountTypeId] = @DiscountTypeId,
		[CreatedTimestamp] = @CreatedTimestamp,
		[EffectiveTimestamp] = @EffectiveTimestamp,
		[TransactionTypeId] = @TransactionTypeId,
		[Description] = @Description,
		[CurrencyId] = @CurrencyId,
		[Quantity] = @Quantity
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

