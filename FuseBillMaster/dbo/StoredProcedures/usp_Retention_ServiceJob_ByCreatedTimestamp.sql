
CREATE PROCEDURE [dbo].[usp_Retention_ServiceJob_ByCreatedTimestamp]
@RetentionDays INT = 365
,@BatchSize INT = 1000
,@AccountId BIGINT = NULL --Optional input parameter to delete by AccountId
AS

SET DEADLOCK_PRIORITY LOW

CREATE TABLE #ServiceJobsToDelete
	(Id BIGINT PRIMARY KEY CLUSTERED)
INSERT #ServiceJobsToDelete
	(Id)
SELECT TOP (@BatchSize) Id
FROM dbo.ServiceJob
WHERE CreatedTimestamp < DATEADD(DD,-@RetentionDays,GETUTCDATE())
AND (@AccountId IS NULL OR AccountId = @AccountId)
ORDER BY Id ASC

BEGIN TRY
	BEGIN TRANSACTION

	DELETE st 
	FROM ServiceTask st
	INNER JOIN #ServiceJobsToDelete del ON del.Id = st.JobId

	DELETE sj
	FROM ServiceJob sj
	INNER JOIN #ServiceJobsToDelete del ON del.Id = sj.Id

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

