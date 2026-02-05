CREATE PROC [dbo].[usp_DeletePlanOrderToCashCycle]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [PlanOrderToCashCycle]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

