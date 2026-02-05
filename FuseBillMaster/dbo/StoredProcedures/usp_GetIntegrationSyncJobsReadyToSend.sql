
CREATE   PROCEDURE [dbo].[usp_GetIntegrationSyncJobsReadyToSend]

AS

SET NOCOUNT ON

SELECT isj.Id 
FROM dbo.IntegrationSynchJob isj
INNER JOIN Account a on a.Id = isj.AccountId
WHERE isj.RequestStatusId = 2 --ReadyToSend
AND isj.ResponseStatusId = 1 -- NotSent
AND isj.ExternalJobId IS NULL
AND a.IncludeInAutomatedProcesses = 1

SET NOCOUNT OFF

GO

