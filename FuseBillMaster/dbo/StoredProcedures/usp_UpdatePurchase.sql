CREATE PROC [dbo].[usp_UpdatePurchase]

	@Id bigint,
	@ProductId bigint,
	@StatusId int,
	@CustomerId bigint,
	@Quantity decimal,
	@Name nvarchar(2000),
	@Description nvarchar(2000),
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime,
	@EffectiveTimestamp datetime,
	@PurchaseTimestamp datetime,
	@PricingModelTypeId int,
	@Amount decimal,
	@TaxableAmount decimal,
	@IsEarnedImmediately bit,
	@EarningInterval int,
	@EarningNumberOfInterval int,
	@IsTrackingItems bit,
	@EarningTimingTypeId int,
	@EarningTimingIntervalId int
AS
SET NOCOUNT ON
	UPDATE [Purchase] SET 
		[ProductId] = @ProductId,
		[StatusId] = @StatusId,
		[CustomerId] = @CustomerId,
		[Quantity] = @Quantity,
		[Name] = @Name,
		[Description] = @Description,
		[CreatedTimestamp] = @CreatedTimestamp,
		[ModifiedTimestamp] = @ModifiedTimestamp,
		[EffectiveTimestamp] = @EffectiveTimestamp,
		[PurchaseTimestamp] = @PurchaseTimestamp,
		[PricingModelTypeId] = @PricingModelTypeId,
		[Amount] = @Amount,
		[TaxableAmount] = @TaxableAmount,
		[IsEarnedImmediately] = @IsEarnedImmediately,
		[EarningInterval] = @EarningInterval,
		[EarningNumberOfInterval] = @EarningNumberOfInterval,
		[IsTrackingItems] = @IsTrackingItems,
		[EarningTimingTypeId] = @EarningTimingTypeId,
		[EarningTimingIntervalId] = @EarningTimingIntervalId
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

