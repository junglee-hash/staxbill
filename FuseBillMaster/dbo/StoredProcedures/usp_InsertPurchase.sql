 
 
CREATE PROC [dbo].[usp_InsertPurchase]

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
	INSERT INTO [Purchase] (
		[ProductId],
		[StatusId],
		[CustomerId],
		[Quantity],
		[Name],
		[Description],
		[CreatedTimestamp],
		[ModifiedTimestamp],
		[EffectiveTimestamp],
		[PurchaseTimestamp],
		[PricingModelTypeId],
		[Amount],
		[TaxableAmount],
		[IsEarnedImmediately],
		[EarningInterval],
		[EarningNumberOfInterval],
		[IsTrackingItems],
		[EarningTimingTypeId],
		[EarningTimingIntervalId]
	)
	VALUES (
		@ProductId,
		@StatusId,
		@CustomerId,
		@Quantity,
		@Name,
		@Description,
		@CreatedTimestamp,
		@ModifiedTimestamp,
		@EffectiveTimestamp,
		@PurchaseTimestamp,
		@PricingModelTypeId,
		@Amount,
		@TaxableAmount,
		@IsEarnedImmediately,
		@EarningInterval,
		@EarningNumberOfInterval,
		@IsTrackingItems,
		@EarningTimingTypeId,
		@EarningTimingIntervalId
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

