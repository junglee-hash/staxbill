CREATE PROC [dbo].[usp_UpdateDraftCharge]

	@Id bigint,
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime,
	@Quantity decimal,
	@UnitPrice money,
	@Amount money,
	@DraftInvoiceId bigint,
	@Name nvarchar(2000),
	@Description nvarchar(2000),
	@TransactionTypeId int,
	@CurrencyId bigint,
	@EffectiveTimestamp datetime,
	@ProratedUnitPrice decimal,
	@RangeQuantity decimal,
	@TaxableAmount decimal,
	@StatusId int,
	@SortOrder tinyint,
	@CustomerId bigint,
	@EarningTimingTypeId int,
	@EarningTimingIntervalId int
AS
SET NOCOUNT ON
	UPDATE [DraftCharge] SET 
		[CreatedTimestamp] = @CreatedTimestamp,
		[ModifiedTimestamp] = @ModifiedTimestamp,
		[Quantity] = @Quantity,
		[UnitPrice] = @UnitPrice,
		[Amount] = @Amount,
		[DraftInvoiceId] = @DraftInvoiceId,
		[Name] = @Name,
		[Description] = @Description,
		[TransactionTypeId] = @TransactionTypeId,
		[CurrencyId] = @CurrencyId,
		[EffectiveTimestamp] = @EffectiveTimestamp,
		[ProratedUnitPrice] = @ProratedUnitPrice,
		[RangeQuantity] = @RangeQuantity,
		[TaxableAmount] = @TaxableAmount,
		[StatusId] = @StatusId,
		[SortOrder] = @SortOrder,
		[CustomerId] = @CustomerId,
		[EarningTimingTypeId] = @EarningTimingTypeId,
		[EarningTimingIntervalId] = @EarningTimingIntervalId
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

