CREATE   PROCEDURE [dbo].[usp_Retention_IntegrationSynchJob_ByCreatedTimestamp]
@RetentionDays INT = 365
,@BatchSize INT = 1000
,@AccountId BIGINT = NULL --Optional input parameter to delete by AccountId
AS

SET DEADLOCK_PRIORITY LOW

CREATE TABLE #IntegrationSynchsToDelete
	(Id BIGINT PRIMARY KEY CLUSTERED)
INSERT #IntegrationSynchsToDelete
	(Id)
SELECT TOP (@BatchSize) Id
FROM dbo.IntegrationSynchJob
WHERE CreatedTimestamp < DATEADD(DD,-@RetentionDays,GETUTCDATE())
AND (@AccountId IS NULL OR AccountId = @AccountId)
ORDER BY Id ASC

--Need to delete the child jobs as well if the parent is being deleted
INSERT #IntegrationSynchsToDelete
	(Id)
SELECT j.Id
FROM dbo.IntegrationSynchJob j
INNER JOIN #IntegrationSynchsToDelete del ON del.Id = j.ParentJobId

BEGIN TRY
	BEGIN TRANSACTION

	DELETE br 
	FROM IntegrationSynchBatchRecord br
	INNER JOIN IntegrationSynchBatch sb ON sb.Id = br.IntegrationSynchBatchId
	INNER JOIN #IntegrationSynchsToDelete del ON del.Id = sb.IntegrationSynchJobId

	DELETE sb 
	FROM IntegrationSynchBatch sb
	INNER JOIN #IntegrationSynchsToDelete del ON del.Id = sb.IntegrationSynchJobId

	DELETE sj
	FROM IntegrationSynchJob sj
	INNER JOIN #IntegrationSynchsToDelete del ON del.Id = sj.Id

	COMMIT TRANSACTION
END TRY

BEGIN CATCH
       IF XACT_STATE() <> 0  
              ROLLBACK TRANSACTION
       DECLARE @ErrorMessage NVARCHAR(4000);
       DECLARE @ErrorSeverity INT;
       DECLARE @ErrorState INT;

       SELECT 
              @ErrorMessage = ERROR_MESSAGE(),
              @ErrorSeverity = ERROR_SEVERITY(),
              @ErrorState = ERROR_STATE();

       RAISERROR 
       (
              @ErrorMessage, -- Message text.
              @ErrorSeverity, -- Severity.
              @ErrorState -- State.
       );
END CATCH

GO

