
CREATE   PROCEDURE [dbo].[usp_Retention_AvalaraLog_ClearInputOutputByCreatedTimestamp]
@RetentionStart DATETIME
,@RetentionEnd DATETIME
,@BatchSize INT = 1000
AS

SET DEADLOCK_PRIORITY LOW

CREATE TABLE #LogsToDelete
	(Id BIGINT PRIMARY KEY CLUSTERED)
INSERT #LogsToDelete
	(Id)
SELECT TOP (@BatchSize) Id
FROM dbo.AvalaraLog
WHERE CreatedTimestamp between @RetentionStart and @RetentionEnd
AND LEN(Input) > 0

BEGIN TRY
	BEGIN TRANSACTION

	UPDATE al SET 
		[Input] = ''
		,[Output] = ''
	FROM dbo.AvalaraLog al
	INNER JOIN #LogsToDelete ltd
		ON ltd.Id = al.Id
	WHERE al.[Input] <> ''

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

