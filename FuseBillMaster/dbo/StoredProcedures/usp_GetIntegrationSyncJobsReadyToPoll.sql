
CREATE   PROCEDURE [dbo].[usp_GetIntegrationSyncJobsReadyToPoll]
	@timeOfTransaction DATETIME
AS

SET NOCOUNT ON

SELECT isj.Id 
FROM dbo.IntegrationSynchJob isj
INNER JOIN Account a on a.Id = isj.AccountId
WHERE isj.RequestStatusId = 1 --sent
AND isj.ResponseStatusId = 2 --in progress
AND (isj.LastPolledTimestamp IS NULL OR isj.LastPolledTimestamp < @timeOfTransaction)
AND a.IncludeInAutomatedProcesses = 1

SET NOCOUNT OFF

GO

