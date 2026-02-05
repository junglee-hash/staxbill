-- =============================================
-- Author:		Jamie Munro
-- Create date: September 24th, 2019
-- Description:	Salesforce is active, not onboarding, customers with sync status enabled, don't have sync record, have sync record with older last sync 
--              and less than 2 failures, no jobs in progress or not sent
-- =============================================
CREATE   PROCEDURE [dbo].[usp_GetSalesforceBulkSyncData]
@AccountId bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @CustomerJobId bigint = NULL, @SubscriptionJobId bigint = NULL, @SubscriptionProductJobId bigint = NULL, @InvoiceJobId bigint = NULL, @PurchaseJobId bigint = NULL
	DECLARE @MaxRetryCount int = 2
	DECLARE @SalesforceSyncOption int

	set @SalesforceSyncOption = (select SalesforceSubscriptionProductsSyncOptionId from dbo.AccountSalesforceConfiguration where id = @AccountId)

	--Customers that need a job created
	SELECT c.Id INTO #CustomerRecords
	FROM Customer c
	WHERE
	c.AccountId = @AccountId
		AND c.SalesforceSynchStatusId = 1
		AND c.IsDeleted = 0
		AND	NOT EXISTS (
			SELECT * FROM SalesforceSyncStatus sfs
			WHERE sfs.EntityTypeId = 3 -- Customer entity
			AND sfs.EntityId = c.Id
			AND (c.ModifiedTimestamp <= sfs.LastSyncTimestamp
				OR sfs.RetryCount >= @MaxRetryCount)
		)

	-- Subscriptions that need a job created
	SELECT s.Id INTO #SubscriptionRecords
	FROM Subscription s
	INNER JOIN Customer c ON c.Id = s.CustomerId
	WHERE c.AccountId = @AccountId
		AND c.SalesforceSynchStatusId = 1
		And c.IsDeleted = 0
		AND NOT EXISTS (
			SELECT * FROM SalesforceSyncStatus sfs
			WHERE sfs.EntityTypeId = 7 -- Subscription entity
			AND sfs.EntityId = s.Id
			AND (s.ModifiedTimestamp <= sfs.LastSyncTimestamp
				OR sfs.RetryCount >= @MaxRetryCount)
		)

	-- Subscription products that need a job created, capping it at 50k records per job
	if @SalesforceSyncOption = 1
		begin
			SELECT TOP 50000 sp.Id, sp.Included INTO #SubscriptionProductRecordsAll
			FROM SubscriptionProduct sp
			INNER JOIN Subscription s ON s.Id = sp.SubscriptionId
			INNER JOIN Customer c ON c.Id = s.CustomerId
			INNER JOIN AccountSalesforceConfiguration asf ON asf.Id = c.AccountId
				AND asf.MaintainSubscriptionProductsInSalesforce = 1
				and asf.SalesforceSubscriptionProductsSyncOptionId = 1
			WHERE c.AccountId = @AccountId
				AND c.SalesforceSynchStatusId = 1
				AND c.IsDeleted = 0
				AND (NOT EXISTS (
					SELECT * FROM SalesforceSyncStatus sfs
					WHERE sfs.EntityTypeId = 14 -- Subscription product entity
					AND sfs.EntityId = sp.Id
					AND (sp.ModifiedTimestamp <= sfs.LastSyncTimestamp
						OR sfs.RetryCount >= @MaxRetryCount)
				) or (sp.SalesforceId is null and (select sfs.RetryCount from SalesforceSyncStatus sfs where sfs.EntityTypeId = 14 and sfs.EntityId = sp.Id) < @MaxRetryCount))
		end

	-- Subscription products that need a job created, capping it at 50k records per job
	if @SalesforceSyncOption = 3
		begin
				SELECT TOP 50000 sp.Id, sp.Included INTO #SubscriptionProductRecordsNone
				FROM SubscriptionProduct sp
				INNER JOIN Subscription s ON s.Id = sp.SubscriptionId
				INNER JOIN Customer c ON c.Id = s.CustomerId
				INNER JOIN AccountSalesforceConfiguration asf ON asf.Id = c.AccountId
					AND asf.MaintainSubscriptionProductsInSalesforce = 1
					and asf.SalesforceSubscriptionProductsSyncOptionId = 3
					and sp.SalesforceId is not null
					and DATALENGTH(sp.SalesforceId) > 0
				WHERE c.AccountId = @AccountId
					AND c.SalesforceSynchStatusId = 1
					AND c.IsDeleted = 0
					AND (EXISTS (
						SELECT * FROM SalesforceSyncStatus sfs
						WHERE sfs.EntityTypeId = 14 -- Subscription product entity
						AND sfs.EntityId = sp.Id
						AND (sp.ModifiedTimestamp <= sfs.LastSyncTimestamp
							OR sfs.RetryCount >= @MaxRetryCount)
					) or sp.SalesforceId is not null and (select sfs.RetryCount from SalesforceSyncStatus sfs where sfs.EntityTypeId = 14 and sfs.EntityId = sp.Id) < @MaxRetryCount)

		end

	-- Subscription products that need a job created, capping it at 25k records per job
	if @SalesforceSyncOption = 2
		begin

			SELECT	c.Id 
			INTO	#tmp1
			FROM	Customer c 
			WHERE	c.AccountId = @AccountId AND 
					c.SalesforceSynchStatusId = 1 AND 
					c.IsDeleted = 0

			CREATE INDEX idx1 ON #tmp1(Id)

			SELECT TOP 25000 sp.Id, sp.Included INTO #SubscriptionProductRecordsNotIncludedOnly
			FROM SubscriptionProduct sp
			INNER JOIN Subscription s ON s.Id = sp.SubscriptionId
			INNER JOIN #tmp1 c ON c.Id = s.CustomerId
			INNER JOIN AccountSalesforceConfiguration asf ON asf.Id = @AccountId
				AND asf.MaintainSubscriptionProductsInSalesforce = 1
				and asf.SalesforceSubscriptionProductsSyncOptionId = 2 		
				and DATALENGTH(sp.SalesforceId) > 0
			INNER JOIN SalesforceSyncStatus sfs ON sfs.AccountId = @AccountId AND sfs.EntityTypeId = 14 AND sfs.EntityId = sp.Id
			WHERE sp.Included = 0
				and sp.SalesforceId is not null
				--Has been sent to SF
				AND sp.SalesforceId IS NOT NULL
				--Has not hit max retry
				AND ISNULL(sfs.RetryCount,0) < @MaxRetryCount
				--Has not been synced recently (ie removed from SF)
				AND sp.ModifiedTimestamp > sfs.LastSyncTimestamp

				SELECT TOP 25000 sp.Id, sp.Included INTO #SubscriptionProductRecordsIncludedOnly
				FROM SubscriptionProduct sp
				INNER JOIN Subscription s ON s.Id = sp.SubscriptionId
				INNER JOIN #tmp1 c ON c.Id = s.CustomerId
				INNER JOIN AccountSalesforceConfiguration asf ON asf.Id = @AccountId
					AND asf.MaintainSubscriptionProductsInSalesforce = 1
					and asf.SalesforceSubscriptionProductsSyncOptionId = 2 
				LEFT JOIN SalesforceSyncStatus sfs ON sfs.AccountId = @AccountId AND sfs.EntityTypeId = 14 AND sfs.EntityId = sp.Id
				WHERE sp.Included = 1
					--Has not hit max retry
					AND ISNULL(sfs.RetryCount,0) < @MaxRetryCount
					--Has not been synced recently (or ever)
					AND sp.ModifiedTimestamp > ISNULL(sfs.LastSyncTimestamp,'19000101')

			DROP TABLE #tmp1
		end

	-- Invoices that need a job created
	SELECT i.Id INTO #InvoiceRecords
	FROM Invoice i
	INNER JOIN InvoiceJournal ij ON i.Id = ij.InvoiceId
		AND ij.IsActive = 1
	INNER JOIN Customer c ON c.Id = i.CustomerId
	WHERE c.AccountId = @AccountId
		AND c.SalesforceSynchStatusId = 1
		AND c.IsDeleted = 0
		AND NOT EXISTS (
			SELECT * FROM SalesforceSyncStatus sfs
			WHERE sfs.EntityTypeId = 11 -- Invoice entity
				AND sfs.EntityId = i.Id
				AND (ij.CreatedTimestamp <= sfs.LastSyncTimestamp
				OR sfs.RetryCount >= @MaxRetryCount)
		)

	-- Purchases that need a job created
	SELECT p.Id INTO #PurchaseRecords
	FROM Purchase p
	INNER JOIN Customer c ON c.Id = p.CustomerId
	WHERE c.AccountId = @AccountId
		AND c.SalesforceSynchStatusId = 1
		And p.IsDeleted = 0
		AND NOT EXISTS (
			SELECT * FROM SalesforceSyncStatus sfs
			WHERE sfs.EntityTypeId = 21 -- Purchase entity
			AND sfs.EntityId = p.Id
			AND (p.ModifiedTimestamp <= sfs.LastSyncTimestamp
				OR sfs.RetryCount >= @MaxRetryCount)
		)

	if @SalesforceSyncOption = 1
		BEGIN
			SELECT Id as EntityId, 14 as EntityTypeId, Included FROM #SubscriptionProductRecordsAll
			UNION ALL
			SELECT Id as EntityId, 3 as EntityTypeId, null FROM #CustomerRecords
			UNION ALL
			SELECT Id as EntityId, 7 as EntityTypeId, null FROM #SubscriptionRecords
			UNION ALL
			SELECT Id as EntityId, 11 as EntityTypeId, null FROM #InvoiceRecords
			UNION ALL
			SELECT Id as EntityId, 21 as EntityTypeId, null FROM #PurchaseRecords

			DROP TABLE #SubscriptionProductRecordsAll
		END
	if @SalesforceSyncOption = 2
		BEGIN
			SELECT Id as EntityId, 14 as EntityTypeId, Included FROM #SubscriptionProductRecordsIncludedOnly
			UNION ALL
			SELECT Id as EntityId, 14 as EntityTypeId, Included FROM #SubscriptionProductRecordsNotIncludedOnly
			UNION ALL
			SELECT Id as EntityId, 3 as EntityTypeId, null FROM #CustomerRecords
			UNION ALL
			SELECT Id as EntityId, 7 as EntityTypeId, null FROM #SubscriptionRecords
			UNION ALL
			SELECT Id as EntityId, 11 as EntityTypeId, null FROM #InvoiceRecords
			UNION ALL
			SELECT Id as EntityId, 21 as EntityTypeId, null FROM #PurchaseRecords

			DROP TABLE #SubscriptionProductRecordsIncludedOnly
			DROP TABLE #SubscriptionProductRecordsNotIncludedOnly
		END
	if @SalesforceSyncOption = 3
		BEGIN
			SELECT Id as EntityId, 14 as EntityTypeId, Included FROM #SubscriptionProductRecordsNone
			UNION ALL
			SELECT Id as EntityId, 3 as EntityTypeId, null FROM #CustomerRecords
			UNION ALL
			SELECT Id as EntityId, 7 as EntityTypeId, null FROM #SubscriptionRecords
			UNION ALL
			SELECT Id as EntityId, 11 as EntityTypeId, null FROM #InvoiceRecords
			UNION ALL
			SELECT Id as EntityId, 21 as EntityTypeId, null FROM #PurchaseRecords

			DROP TABLE #SubscriptionProductRecordsNone
		END

	DROP TABLE #CustomerRecords
	DROP TABLE #SubscriptionRecords
	DROP TABLE #InvoiceRecords
	DROP TABLE #PurchaseRecords
END

GO

