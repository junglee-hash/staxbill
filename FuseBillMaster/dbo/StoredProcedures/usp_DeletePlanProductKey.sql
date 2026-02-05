CREATE PROC [dbo].[usp_DeletePlanProductKey]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [PlanProductKey]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

