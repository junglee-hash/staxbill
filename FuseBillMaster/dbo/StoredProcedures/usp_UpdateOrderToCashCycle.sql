CREATE PROC [dbo].[usp_UpdateOrderToCashCycle]

	@Id bigint,
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime,
	@PricingModelTypeId int,
	@IsEarnedImmediately bit,
	@EarningInterval int,
	@EarningNumberOfInterval int,
	@EarningTimingTypeId int,
	@EarningTimingIntervalId int
AS
SET NOCOUNT ON
	UPDATE [OrderToCashCycle] SET 
		[CreatedTimestamp] = @CreatedTimestamp,
		[ModifiedTimestamp] = @ModifiedTimestamp,
		[PricingModelTypeId] = @PricingModelTypeId,
		[IsEarnedImmediately] = @IsEarnedImmediately,
		[EarningInterval] = @EarningInterval,
		[EarningNumberOfInterval] = @EarningNumberOfInterval,
		[EarningTimingTypeId] = @EarningTimingTypeId,
		[EarningTimingIntervalId] = @EarningTimingIntervalId
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

