CREATE PROC [dbo].[usp_DeleteIntegrationSynchJob]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [IntegrationSynchJob]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

