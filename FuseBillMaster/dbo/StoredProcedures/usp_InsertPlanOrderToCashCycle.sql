 
 
CREATE PROC [dbo].[usp_InsertPlanOrderToCashCycle]

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
	INSERT INTO [PlanOrderToCashCycle] (
		[Id],
		[PlanProductId],
		[PlanFrequencyId],
		[RecurChargeTimingTypeId],
		[RecurProrateGranularityId],
		[RecurProrateNegativeQuantity],
		[RecurProratePositiveQuantity],
		[RecurReverseChargeNegativeQuantity],
		[QuantityChargeTimingTypeId],
		[QuantityProrateGranularityId],
		[QuantityProrateNegativeQuantity],
		[QuantityProratePositiveQuantity],
		[QuantityReverseChargeNegativeQuantity],
		[RemainingInterval]
	)
	VALUES (
		@Id,
		@PlanProductId,
		@PlanFrequencyId,
		@RecurChargeTimingTypeId,
		@RecurProrateGranularityId,
		@RecurProrateNegativeQuantity,
		@RecurProratePositiveQuantity,
		@RecurReverseChargeNegativeQuantity,
		@QuantityChargeTimingTypeId,
		@QuantityProrateGranularityId,
		@QuantityProrateNegativeQuantity,
		@QuantityProratePositiveQuantity,
		@QuantityReverseChargeNegativeQuantity,
		@RemainingInterval
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

