CREATE PROC [dbo].[usp_UpdatePlanFrequencyKey]

	@Id bigint,
	@CreatedTimestamp datetime
AS
SET NOCOUNT ON
	UPDATE [PlanFrequencyKey] SET 
		[CreatedTimestamp] = @CreatedTimestamp
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

