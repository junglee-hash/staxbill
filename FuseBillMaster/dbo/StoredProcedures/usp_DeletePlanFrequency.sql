CREATE PROC [dbo].[usp_DeletePlanFrequency]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [PlanFrequency]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

