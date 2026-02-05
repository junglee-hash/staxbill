CREATE PROC [dbo].[usp_DeletePlanFrequencyCustomField]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [PlanFrequencyCustomField]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

