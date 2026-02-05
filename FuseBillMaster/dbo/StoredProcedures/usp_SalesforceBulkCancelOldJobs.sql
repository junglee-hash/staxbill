
CREATE PROCEDURE [dbo].[usp_SalesforceBulkCancelOldJobs]
	@DaysOld INT
	, @RunDate DATETIME
AS

SET NOCOUNT, XACT_ABORT ON;

BEGIN TRANSACTION

DECLARE @IntegrationSyncList TABLE (IntegrationSynchJobId BIGINT)

INSERT INTO @IntegrationSyncList
SELECT Id
FROM IntegrationSynchJob
WHERE IntegrationTypeId = 1 -- Salesforce
	AND RequestStatusId IN (2, 3) -- Ready OR Pending
	AND DATEDIFF(DAY, CreatedTimestamp, @RunDate) >= @DaysOld


-- Update all job statuses to will not send
UPDATE job
	SET job.RequestStatusId = 4 -- Will not send
FROM IntegrationSynchJob job
INNER JOIN @IntegrationSyncList i ON job.Id = i.IntegrationSynchJobId


COMMIT TRANSACTION

SET NOCOUNT, XACT_ABORT OFF;


SELECT COUNT(*) FROM @IntegrationSyncList

GO

