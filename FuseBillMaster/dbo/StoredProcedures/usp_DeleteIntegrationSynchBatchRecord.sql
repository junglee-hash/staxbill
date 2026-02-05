CREATE PROC [dbo].[usp_DeleteIntegrationSynchBatchRecord]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [IntegrationSynchBatchRecord]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

