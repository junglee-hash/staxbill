CREATE PROC [dbo].[usp_DeleteIntegrationSynchBatch]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [IntegrationSynchBatch]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

