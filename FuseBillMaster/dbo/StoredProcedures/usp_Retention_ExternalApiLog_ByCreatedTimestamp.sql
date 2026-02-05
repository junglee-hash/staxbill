
CREATE PROCEDURE [dbo].[usp_Retention_ExternalApiLog_ByCreatedTimestamp]
@RetentionDays INT = 60
,@BatchSize INT = 1000
,@AccountId BIGINT = NULL --Optional input parameter to delete by AccountId
AS

SET DEADLOCK_PRIORITY LOW

CREATE TABLE #LogsToDelete
	(Id BIGINT PRIMARY KEY CLUSTERED)
INSERT #LogsToDelete
	(Id)
SELECT TOP (@BatchSize) Id
FROM dbo.ExternalApiLog
WHERE CreatedTimestamp < DATEADD(DD,-@RetentionDays,GETUTCDATE())
AND (@AccountId IS NULL OR AccountId = @AccountId) --This needs an Index. Perhaps CreatedTimestamp/AccountId
AND [Output] <> '' --Prevents records from being updated twice

BEGIN TRY
	BEGIN TRANSACTION

	UPDATE al SET 
		[Input] = ''
		,[Output] = ''
	FROM dbo.ExternalApiLog al
	INNER JOIN #LogsToDelete ltd
		ON ltd.Id = al.Id

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

