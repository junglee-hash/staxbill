CREATE PROCEDURE [dbo].[usp_PopulateSalesforceEntitySync]
	@AccountId BIGINT
AS

INSERT INTO [dbo].[SalesforceSyncStatus]
           ([AccountId]
           ,[ParentEntityId]
           ,[EntityId]
           ,[EntityTypeId]
           ,[LastSyncTimestamp]
           ,[CreatedTimestamp]
           ,[ModifiedTimestamp]
           ,[RetryCount])
SELECT
	@AccountId as AccountId
	,NULL as ParentId
	,c.Id as EntityId
	,3 as EntityTypeId
	,GETUTCDATE() as LastSyncTimestamp
	,GETUTCDATE() as CreatedTimestamp
    ,GETUTCDATE() as ModifiedTimestamp
    ,0 as RetryCount
FROM Customer c
WHERE c.AccountId = @AccountId
	AND c.SalesforceSynchStatusId = 1 --Enabled
	AND NOT EXISTS (
		SELECT
			c.Id
		FROM SalesforceSyncStatus ss
		WHERE ss.EntityId = c.Id
			AND ss.EntityTypeId = 3
			AND ss.AccountId = @AccountId
	)

INSERT INTO [dbo].[SalesforceSyncStatus]
        ([AccountId]
        ,[ParentEntityId]
        ,[EntityId]
        ,[EntityTypeId]
        ,[LastSyncTimestamp]
        ,[CreatedTimestamp]
        ,[ModifiedTimestamp]
        ,[RetryCount])
SELECT
	@AccountId as AccountId
	,NULL as ParentId
	,s.Id as EntityId
	,7 as EntityTypeId
	,GETUTCDATE() as LastSyncTimestamp
	,GETUTCDATE() as CreatedTimestamp
    ,GETUTCDATE() as ModifiedTimestamp
    ,0 as RetryCount
FROM Subscription s
INNER JOIN Customer c ON c.Id = s.CustomerId
WHERE c.AccountId = @AccountId
	AND c.SalesforceSynchStatusId = 1 --Enabled
	AND NOT EXISTS (
		SELECT
			s.Id
		FROM SalesforceSyncStatus ss
		WHERE ss.EntityId = s.Id
			AND ss.EntityTypeId = 7
			AND ss.AccountId = @AccountId
	)

INSERT INTO [dbo].[SalesforceSyncStatus]
           ([AccountId]
           ,[ParentEntityId]
           ,[EntityId]
           ,[EntityTypeId]
           ,[LastSyncTimestamp]
           ,[CreatedTimestamp]
           ,[ModifiedTimestamp]
           ,[RetryCount])
SELECT
	@AccountId as AccountId
	,s.Id as ParentId
	,sp.Id as EntityId
	,14 as EntityTypeId
	,GETUTCDATE() as LastSyncTimestamp
	,GETUTCDATE() as CreatedTimestamp
    ,GETUTCDATE() as ModifiedTimestamp
    ,0 as RetryCount
FROM SubscriptionProduct sp
INNER JOIN Subscription s ON s.Id = sp.SubscriptionId
INNER JOIN Customer c ON c.Id = s.CustomerId
WHERE c.AccountId = @AccountId
	AND c.SalesforceSynchStatusId = 1 --Enabled
	AND NOT EXISTS (
		SELECT
			sp.Id
		FROM SalesforceSyncStatus ss
		WHERE ss.EntityId = sp.Id
			AND ss.EntityTypeId = 14
			AND ss.AccountId = @AccountId
	)

INSERT INTO [dbo].[SalesforceSyncStatus]
           ([AccountId]
           ,[ParentEntityId]
           ,[EntityId]
           ,[EntityTypeId]
           ,[LastSyncTimestamp]
           ,[CreatedTimestamp]
           ,[ModifiedTimestamp]
           ,[RetryCount])
SELECT
	@AccountId as AccountId
	,NULL as ParentId
	,s.Id as EntityId
	,11 as EntityTypeId
	,GETUTCDATE() as LastSyncTimestamp
	,GETUTCDATE() as CreatedTimestamp
    ,GETUTCDATE() as ModifiedTimestamp
    ,0 as RetryCount
FROM Invoice s
INNER JOIN Customer c ON c.Id = s.CustomerId
WHERE c.AccountId = @AccountId
	AND c.SalesforceSynchStatusId = 1 --Enabled
	AND NOT EXISTS (
		SELECT
			s.Id
		FROM SalesforceSyncStatus ss
		WHERE ss.EntityId = s.Id
			AND ss.EntityTypeId = 11
			AND ss.AccountId = @AccountId
	)

INSERT INTO [dbo].[SalesforceSyncStatus]
           ([AccountId]
           ,[ParentEntityId]
           ,[EntityId]
           ,[EntityTypeId]
           ,[LastSyncTimestamp]
           ,[CreatedTimestamp]
           ,[ModifiedTimestamp]
           ,[RetryCount])
SELECT
	@AccountId as AccountId
	,NULL as ParentId
	,s.Id as EntityId
	,21 as EntityTypeId
	,GETUTCDATE() as LastSyncTimestamp
	,GETUTCDATE() as CreatedTimestamp
    ,GETUTCDATE() as ModifiedTimestamp
    ,0 as RetryCount
FROM Purchase s
INNER JOIN Customer c ON c.Id = s.CustomerId
WHERE c.AccountId = @AccountId
	AND c.SalesforceSynchStatusId = 1 --Enabled
	AND NOT EXISTS (
		SELECT
			s.Id
		FROM SalesforceSyncStatus ss
		WHERE ss.EntityId = s.Id
			AND ss.EntityTypeId = 21
			AND ss.AccountId = @AccountId
	)

GO

