CREATE PROC [dbo].[usp_UpdatePlanOrderToCashCycle]

	@Id bigint,
	@PlanProductId bigint,
	@PlanFrequencyId bigint,
	@RecurChargeTimingTypeId int,
	@RecurProrateGranularityId int,
	@RecurProrateNegativeQuantity bit,
	@RecurProratePositiveQuantity bit,
	@RecurReverseChargeNegativeQuantity bit,
	@QuantityChargeTimingTypeId int,
	@QuantityProrateGranularityId int,
	@QuantityProrateNegativeQuantity bit,
	@QuantityProratePositiveQuantity bit,
	@QuantityReverseChargeNegativeQuantity bit,
	@RemainingInterval int
AS
SET NOCOUNT ON
	UPDATE [PlanOrderToCashCycle] SET 
		[PlanProductId] = @PlanProductId,
		[PlanFrequencyId] = @PlanFrequencyId,
		[RecurChargeTimingTypeId] = @RecurChargeTimingTypeId,
		[RecurProrateGranularityId] = @RecurProrateGranularityId,
		[RecurProrateNegativeQuantity] = @RecurProrateNegativeQuantity,
		[RecurProratePositiveQuantity] = @RecurProratePositiveQuantity,
		[RecurReverseChargeNegativeQuantity] = @RecurReverseChargeNegativeQuantity,
		[QuantityChargeTimingTypeId] = @QuantityChargeTimingTypeId,
		[QuantityProrateGranularityId] = @QuantityProrateGranularityId,
		[QuantityProrateNegativeQuantity] = @QuantityProrateNegativeQuantity,
		[QuantityProratePositiveQuantity] = @QuantityProratePositiveQuantity,
		[QuantityReverseChargeNegativeQuantity] = @QuantityReverseChargeNegativeQuantity,
		[RemainingInterval] = @RemainingInterval
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

