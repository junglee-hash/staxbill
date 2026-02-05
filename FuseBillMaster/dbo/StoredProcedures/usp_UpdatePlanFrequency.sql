CREATE PROC [dbo].[usp_UpdatePlanFrequency]

	@Id bigint,
	@PlanRevisionId bigint,
	@NumberOfIntervals int,
	@Interval int,
	@StatusId int,
	@PlanFrequencyUniqueId bigint,
	@NumberOfSubscriptions int
AS
SET NOCOUNT ON
	UPDATE [PlanFrequency] SET 
		[PlanRevisionId] = @PlanRevisionId,
		[NumberOfIntervals] = @NumberOfIntervals,
		[Interval] = @Interval,
		[StatusId] = @StatusId,
		[PlanFrequencyUniqueId] = @PlanFrequencyUniqueId,
		[NumberOfSubscriptions] = @NumberOfSubscriptions
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

