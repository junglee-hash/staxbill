CREATE PROC [dbo].[usp_DeletePlanProduct]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [PlanProduct]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

