CREATE PROC [dbo].[usp_DeletePlanProductFrequencyCustomField]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [PlanProductFrequencyCustomField]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

