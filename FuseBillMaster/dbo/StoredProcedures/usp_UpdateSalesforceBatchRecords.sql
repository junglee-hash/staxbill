CREATE PROCEDURE [dbo].[usp_UpdateSalesforceBatchRecords]
 @BatchId bigint,
 @EntityTypeId int,
 @SalesforceIds nvarchar(max),
 @Successes nvarchar(max),
 @Failures nvarchar(max)

AS 

set transaction isolation level snapshot

BEGIN TRAN
	
	--Get the BatchRecords into a tmp order by Id Asec
	SELECT IDENTITY(bigint) AS tmpId
	, sfbr.EntityId AS EntityId 
	INTO 
	#tmp_SalesforceBatchRecord 
	FROM dbo.IntegrationSynchBatchRecord sfbr 
	WHERE sfbr.EntityTypeId = @EntityTypeId AND sfbr.IntegrationSynchBatchId = @BatchId 
	ORDER By sfbr.EntityId 

	SELECT * INTO #tmp_SalesforceIds FROM dbo.Split(@SalesforceIds, '|')	
	SELECT * INTO #tmp_SalesforceSuccesses FROM dbo.Split(@Successes, '|')
	SELECT * INTO #tmp_SalesforceFailures FROM dbo.Split(@Failures, '|')

	DECLARE @success as nvarchar(25) -- currenct record success flag
	DECLARE @salesforceId as nvarchar(255) -- current record salesfroceId from the SalesforceIds
	DECLARE @salesforceBatchRecordId as bigint -- current SalesforceBatchRecord.Id
	DECLARE @entityId as bigint -- current Entity Id
	DECLARE @FailureMsg as nvarchar(max) -- current Failures

			
					Update SFBR
					 SET 
					 ExternalId = sfId.Data 
					 , sfbr.FailureReason = f.Data 
					 FROM
						IntegrationSynchBatchRecord sfbr
						inner join #tmp_SalesforceBatchRecord tsfbr
						on sfbr.EntityId = tsfbr.EntityId and sfbr.IntegrationSynchBatchId = @BatchId AND EntityTypeId = @EntityTypeId
						inner join #tmp_SalesforceIds sfId
						on tsfbr.tmpId = sfId.Id
						inner join #tmp_SalesforceSuccesses s
						on sfid.Id = s.Id 
						inner join #tmp_SalesforceFailures f
						on sfid.id = f.Id 
					 			
					IF(@EntityTypeId = '3') 
						Update C
						SET 
						SalesforceId = r.ExternalId 
						from Customer c
						inner join IntegrationSynchBatchRecord r
						on c.Id = r.EntityId AND r.EntityTypeId = @EntityTypeId AND r.IntegrationSynchBatchId = @BatchId
						WHERE r.FailureReason = ''

					IF(@EntityTypeId = '7')
						Update s
						SET 
						SalesforceId = r.ExternalId 
						from Subscription  s
						inner join IntegrationSynchBatchRecord r
						on s.Id = r.EntityId AND r.EntityTypeId = @EntityTypeId AND r.IntegrationSynchBatchId = @BatchId
						WHERE r.FailureReason = ''
				
					IF(@EntityTypeId = '11') 
					Update I
						SET 
						SalesforceId = r.ExternalId 
						from Invoice I
						inner join IntegrationSynchBatchRecord r
						on I.Id = r.EntityId AND r.EntityTypeId = @EntityTypeId AND r.IntegrationSynchBatchId = @BatchId
						WHERE r.FailureReason = ''

					IF(@EntityTypeId = '14') 
					Update sp
						SET 
						SalesforceId = r.ExternalId 
						from SubscriptionProduct  sp
						inner join IntegrationSynchBatchRecord r 
						on sp.Id = r.EntityId AND r.EntityTypeId = @EntityTypeId AND r.IntegrationSynchBatchId = @BatchId
						WHERE r.FailureReason = ''

COMMIT TRAN

SELECT COUNT(*) FROM dbo.IntegrationSynchBatchRecord sfbr WHERE sfbr.EntityTypeId = @EntityTypeId AND sfbr.IntegrationSynchBatchId = @BatchId

GO

