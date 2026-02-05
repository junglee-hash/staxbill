CREATE PROC [dbo].[usp_DeletePlan]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [Plan]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

