CREATE PROCEDURE [dbo].[usp_UpdateIntegrationSyncBatchRecords]
 @BatchId bigint,
 @ExternalIds nvarchar(max),
 @Successes nvarchar(max),
 @Failures nvarchar(max)

AS 

IF @@TRANCOUNT = 0
BEGIN
	set transaction isolation level snapshot
END
	
	--Get the BatchRecords into a tmp order by Id Asec
	SELECT IDENTITY(bigint) AS tmpId
	, sfbr.EntityId AS EntityId 
	INTO 
	#tmp_IntegrationSyncBatchRecord 
	FROM dbo.IntegrationSynchBatchRecord sfbr 
	WHERE sfbr.IntegrationSynchBatchId = @BatchId 
	ORDER By sfbr.EntityId 

	SELECT * INTO #tmp_IntegrationSyncIds FROM dbo.Split(@ExternalIds, '|')	
	SELECT * INTO #tmp_IntegrationSyncSuccesses FROM dbo.Split(@Successes, '|')
	SELECT * INTO #tmp_IntegrationSyncFailures FROM dbo.Split(@Failures, '|')

	DECLARE @success as nvarchar(25) -- currenct record success flag
	DECLARE @integrationType int 
	DECLARE @EntityTypeId int
	DECLARE @integrationSyncId as nvarchar(255) -- current record salesfroceId from the integrationSyncIds
	DECLARE @integrationSyncBatchRecordId as bigint -- current integrationSyncBatchRecord.Id
	DECLARE @entityId as bigint -- current Entity Id
	DECLARE @FailureMsg as nvarchar(max) -- current Failures
	DECLARE @IsUpsert as bit

	SELECT 
		@EntityTypeId = j.EntityTypeId,
		@integrationType = j.IntegrationTypeId,
		@IsUpsert = CASE WHEN j.Operation != 'delete' THEN 1 ELSE 0 END
	FROM IntegrationSynchBatch b
	INNER JOIN IntegrationSynchJob j ON j.Id = b.IntegrationSynchJobId
	WHERE b.Id = @BatchId

	Update SFBR
		SET 
		ExternalId = CASE WHEN isj.Operation = 'delete' THEN NULL ELSE sfId.Data END
		, sfbr.FailureReason = f.Data 
		, sfbr.StatusId = case when len(f.Data) > 0 then 3 ELSE 2 END
		FROM
		IntegrationSynchBatchRecord sfbr
		INNER JOIN IntegrationSynchBatch isb ON isb.Id = sfbr.IntegrationSynchBatchId
		INNER JOIN IntegrationSynchJob isj ON isj.Id = isb.IntegrationSynchJobId
		inner join #tmp_IntegrationSyncBatchRecord tsfbr
		on sfbr.EntityId = tsfbr.EntityId and sfbr.IntegrationSynchBatchId = @BatchId AND sfbr.EntityTypeId = @EntityTypeId
		inner join #tmp_IntegrationSyncIds sfId
		on tsfbr.tmpId = sfId.Id
		inner join #tmp_IntegrationSyncSuccesses s
		on sfid.Id = s.Id 
		inner join #tmp_IntegrationSyncFailures f
		on sfid.id = f.Id 
					 			
	IF(@EntityTypeId = '3') 
		BEGIN
			Update C
			SET 
			SalesforceId = CASE WHEN @integrationType = 1 THEN r.ExternalId ELSE SalesforceId END
			,NetsuiteId = CASE WHEN @integrationType = 2 THEN r.ExternalId ELSE NetsuiteId END
			,NetsuiteSyncTimestamp = CASE WHEN @integrationType = 2 THEN GETUTCDATE() ELSE NetsuiteSyncTimestamp END
			,ModifiedTimestamp = GETUTCDATE()
			from Customer c
			inner join IntegrationSynchBatchRecord r
			on c.Id = r.EntityId AND r.EntityTypeId = @EntityTypeId AND r.IntegrationSynchBatchId = @BatchId
			WHERE r.FailureReason = ''
		END

	IF(@EntityTypeId = '7')
		Update s
		SET 
		SalesforceId = CASE WHEN @integrationType = 1 THEN r.ExternalId ELSE SalesforceId END
		,NetsuiteId = CASE WHEN @integrationType = 2 THEN r.ExternalId ELSE NetsuiteId END
		,ModifiedTimestamp = GETUTCDATE()
		from Subscription  s
		inner join IntegrationSynchBatchRecord r
		on s.Id = r.EntityId AND r.EntityTypeId = @EntityTypeId AND r.IntegrationSynchBatchId = @BatchId
		WHERE r.FailureReason = ''
				
	IF(@EntityTypeId = '11') 
	Update I
		SET 
		SalesforceId = CASE WHEN @integrationType = 1 THEN r.ExternalId ELSE SalesforceId END
		,NetsuiteId = CASE WHEN @integrationType = 2 THEN r.ExternalId ELSE NetsuiteId END
		from Invoice I
		inner join IntegrationSynchBatchRecord r
		on I.Id = r.EntityId AND r.EntityTypeId = @EntityTypeId AND r.IntegrationSynchBatchId = @BatchId
		WHERE r.FailureReason = ''

	IF(@EntityTypeId = '14') 
	Update sp
		SET 
		SalesforceId = CASE WHEN @integrationType = 1 THEN r.ExternalId ELSE SalesforceId END
		,NetsuiteId = CASE WHEN @integrationType = 2 THEN r.ExternalId ELSE NetsuiteId END
		,ModifiedTimestamp = GETUTCDATE()
		from SubscriptionProduct  sp
		inner join IntegrationSynchBatchRecord r 
		on sp.Id = r.EntityId AND r.EntityTypeId = @EntityTypeId AND r.IntegrationSynchBatchId = @BatchId
		WHERE r.FailureReason = ''
				
	IF(@EntityTypeId = '21') 
	Update p
		SET 
		SalesforceId = CASE WHEN @integrationType = 1 THEN r.ExternalId ELSE SalesforceId END
		--,NetsuiteId = CASE WHEN @integrationType = 2 THEN r.ExternalId ELSE NetsuiteId END
		,ModifiedTimestamp = GETUTCDATE()
		from Purchase p
		inner join IntegrationSynchBatchRecord r
		on p.Id = r.EntityId AND r.EntityTypeId = @EntityTypeId AND r.IntegrationSynchBatchId = @BatchId
		WHERE r.FailureReason = ''



	--- Track Salesforce Sync Status
	IF @integrationType = 1
	BEGIN
		IF @IsUpsert = 1
		BEGIN
			-- Generic tracking for every entity type except Subscription Product
			IF @EntityTypeId != 14
			BEGIN
				MERGE INTO SalesforceSyncStatus as Target
				USING (SELECT bs.AccountId, br.EntityId, br.EntityTypeId, br.FailureReason
					FROM IntegrationSynchBatchRecord br
					INNER JOIN IntegrationSynchBatch b ON b.Id = br.IntegrationSynchBatchId
					INNER JOIN IntegrationSynchJob bs ON bs.Id = b.IntegrationSynchJobId
					WHERE br.IntegrationSynchBatchId = @BatchId
						AND br.EntityTypeId != 14
					) as Source
				ON Target.AccountId = Source.AccountId
					AND Target.EntityId = Source.EntityId
					AND Target.EntityTypeId = Source.EntityTypeId

				WHEN MATCHED THEN UPDATE SET
					Target.[LastSyncTimestamp] = CASE WHEN Source.FailureReason = '' THEN GETUTCDATE() ELSE '1900-01-01' END
					, Target.[ModifiedTimestamp] = GETUTCDATE()
					, Target.RetryCount = CASE WHEN Source.FailureReason = '' THEN 0 ELSE Target.RetryCount + 1 END

				WHEN NOT MATCHED BY Target THEN 
					INSERT ([AccountId], [ParentEntityId], [EntityId], [EntityTypeId], [LastSyncTimestamp], [CreatedTimestamp], [ModifiedTimestamp], [RetryCount])
					VALUES (
						Source.AccountId
						, NULL
						, Source.EntityId
						, Source.EntityTypeId
						, CASE WHEN Source.FailureReason = '' THEN GETUTCDATE() ELSE '1900-01-01' END
						, GETUTCDATE()
						, GETUTCDATE()
						, CASE WHEN Source.FailureReason = '' THEN 0 ELSE 1 END
					);
			END
			-- Need to track parent entity ID when subscription product
			ELSE
			BEGIN
				MERGE INTO SalesforceSyncStatus as Target
				USING (SELECT bs.AccountId, br.EntityId, br.EntityTypeId, sp.SubscriptionId, br.FailureReason
					FROM IntegrationSynchBatchRecord br
					INNER JOIN IntegrationSynchBatch b ON b.Id = br.IntegrationSynchBatchId
					INNER JOIN IntegrationSynchJob bs ON bs.Id = b.IntegrationSynchJobId
					INNER JOIN SubscriptionProduct sp ON sp.Id = br.EntityId
					WHERE br.IntegrationSynchBatchId = @BatchId
						AND br.EntityTypeId = 14
					) as Source
				ON Target.AccountId = Source.AccountId
					AND Target.EntityId = Source.EntityId
					AND Target.EntityTypeId = Source.EntityTypeId

				WHEN MATCHED THEN UPDATE SET
					Target.[LastSyncTimestamp] = CASE WHEN Source.FailureReason = '' THEN GETUTCDATE() ELSE '1900-01-01' END
					, Target.[ModifiedTimestamp] = GETUTCDATE()
					, Target.RetryCount = CASE WHEN Source.FailureReason = '' THEN 0 ELSE Target.RetryCount + 1 END

				WHEN NOT MATCHED BY Target THEN 
					INSERT ([AccountId], [ParentEntityId], [EntityId], [EntityTypeId], [LastSyncTimestamp], [CreatedTimestamp], [ModifiedTimestamp], [RetryCount])
					VALUES (
						Source.AccountId
						, Source.SubscriptionId
						, Source.EntityId
						, Source.EntityTypeId
						, CASE WHEN Source.FailureReason = '' THEN GETUTCDATE() ELSE '1900-01-01' END
						, GETUTCDATE()
						, GETUTCDATE()
						, CASE WHEN Source.FailureReason = '' THEN 0 ELSE 1 END
					);
			END
		END
		ELSE
		BEGIN
			-- Delete from Sync Status table when the external ID is empty
			DELETE sf 
			FROM SalesforceSyncStatus sf
			INNER JOIN IntegrationSynchBatchRecord br ON
				sf.EntityId = br.EntityId
				AND sf.EntityTypeId = br.EntityTypeId
			WHERE br.IntegrationSynchBatchId = @BatchId -- Delete all sync statuses for any entity in the batch

			-- Delete Subscription Product sync status based on the parent entity ID when the batch records entity ID is subscription
			DELETE sf
			FROM SalesforceSyncStatus sf
			INNER JOIN IntegrationSynchBatchRecord br ON
				sf.ParentEntityId = br.EntityId
					AND br.EntityTypeId = 7 -- Batch record entity type is subscription
			WHERE br.IntegrationSynchBatchId = @BatchId
				AND sf.EntityTypeId = 14 -- Salesforce sync entity is subscription product
		END

	END

SELECT COUNT(*) FROM dbo.IntegrationSynchBatchRecord sfbr WHERE sfbr.EntityTypeId = @EntityTypeId AND sfbr.IntegrationSynchBatchId = @BatchId

GO

