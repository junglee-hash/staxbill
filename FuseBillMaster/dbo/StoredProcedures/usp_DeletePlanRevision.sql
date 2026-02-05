CREATE PROC [dbo].[usp_DeletePlanRevision]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [PlanRevision]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

