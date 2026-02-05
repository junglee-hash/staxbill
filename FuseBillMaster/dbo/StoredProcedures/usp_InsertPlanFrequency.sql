 
 
CREATE PROC [dbo].[usp_InsertPlanFrequency]

	@PlanRevisionId bigint,
	@NumberOfIntervals int,
	@Interval int,
	@StatusId int,
	@PlanFrequencyUniqueId bigint,
	@NumberOfSubscriptions int
AS
SET NOCOUNT ON
	INSERT INTO [PlanFrequency] (
		[PlanRevisionId],
		[NumberOfIntervals],
		[Interval],
		[StatusId],
		[PlanFrequencyUniqueId],
		[NumberOfSubscriptions]
	)
	VALUES (
		@PlanRevisionId,
		@NumberOfIntervals,
		@Interval,
		@StatusId,
		@PlanFrequencyUniqueId,
		@NumberOfSubscriptions
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

