
CREATE   PROCEDURE [dbo].[usp_UpsertSalesforceSynchStatus]
	@AccountId BIGINT,
	@EntityTypeId int,
	@entityId BIGINT,
	@parentEntityId BIGINT = NULL
AS

	SELECT @EntityTypeId AS EntityTypeId, 
	   @entityId AS EntityId 
	INTO #parameters

	MERGE dbo.SalesforceSyncStatus as Target
	USING #parameters as Source
	ON Source.EntityTypeId = Target.EntityTypeID AND Source.EntityId = Target.EntityId
	
	WHEN NOT MATCHED BY TARGET THEN
	INSERT (AccountId, ParentEntityId, EntityId, EntityTypeId, LastSyncTimestamp, CreatedTimestamp,ModifiedTimestamp,REtryCount)
	Values (@AccountId, @parentEntityId, Source.EntityId, Source.EntityTypeId, GETUTCDATE(), GETUTCDATE(), GETUTCDATE(), 0)
	
	WHEN MATCHED THEN UPDATE SET
    Target.RetryCount = 0,
	Target.LastSyncTimestamp = GETUTCDATE(),
	Target.ModifiedTimestamp = GETUTCDATE();

DROP TABLE #parameters

GO

