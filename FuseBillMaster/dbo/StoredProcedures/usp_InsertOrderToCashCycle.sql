 
 
CREATE PROC [dbo].[usp_InsertOrderToCashCycle]

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
	INSERT INTO [OrderToCashCycle] (
		[CreatedTimestamp],
		[ModifiedTimestamp],
		[PricingModelTypeId],
		[IsEarnedImmediately],
		[EarningInterval],
		[EarningNumberOfInterval],
		[EarningTimingTypeId],
		[EarningTimingIntervalId]
	)
	VALUES (
		@CreatedTimestamp,
		@ModifiedTimestamp,
		@PricingModelTypeId,
		@IsEarnedImmediately,
		@EarningInterval,
		@EarningNumberOfInterval,
		@EarningTimingTypeId,
		@EarningTimingIntervalId
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

