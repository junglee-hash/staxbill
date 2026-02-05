CREATE PROC [dbo].[usp_DeletePlanFrequencyKey]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [PlanFrequencyKey]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

