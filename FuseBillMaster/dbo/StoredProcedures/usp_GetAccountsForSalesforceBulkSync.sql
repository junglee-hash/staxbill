-- =============================================
-- Author:		Jamie Munro
-- Create date: September 24th, 2019
-- Description:	Salesforce is active, not onboarding, customers with sync status enabled, don't have sync record, have sync record with older last sync 
--              and less than 2 failures, no jobs in progress or not sent
-- =============================================
CREATE     PROCEDURE [dbo].[usp_GetAccountsForSalesforceBulkSync]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
		SET NOCOUNT ON;

		DECLARE @MaxRetryCount int = 2

		-- Temp table of Accounts with Salesforce enabled and no pending jobs
		SELECT 
			sf.Id 
			,sf.MaintainSubscriptionProductsInSalesforce
			,sf.SalesforceSubscriptionProductsSyncOptionId
		INTO #AccountsWithSalesforceEnabled
		FROM AccountSalesforceConfiguration sf
		INNER JOIN AccountFeatureConfiguration afc ON sf.Id = afc.Id
			AND sf.IsActive = 1 -- Salesforce is active
			AND afc.SalesforceBulkSyncEnabled = 1 -- Bulk sync is active
		INNER JOIN Account a ON a.Id = sf.Id
		WHERE 
			a.IncludeInAutomatedProcesses = 1 AND
			NOT  (		-- Account has existing SF jobs don't return
				EXISTS (SELECT * FROM IntegrationSynchJob job
				WHERE job.AccountId = sf.Id
					AND job.IntegrationTypeId = 1
					AND (job.RequestStatusId IN (2, 3) or job.ResponseStatusId = 2)
					--Assume any jobs that have not been modified in 48 hours crashed unexpectedly and will not run again
					AND job.ModifiedTimestamp >= DATEADD(DAY,-2,GETUTCDATE())
					)
			)

		-- Accounts with customers out of sync
		SELECT sf.Id INTO #Accounts
		FROM #AccountsWithSalesforceEnabled sf
		INNER JOIN Customer c ON sf.Id = c.AccountId
			AND c.SalesforceSynchStatusId = 1
			AND c.IsDeleted = 0
		WHERE
		NOT EXISTS (
				SELECT * FROM SalesforceSyncStatus sfs
				WHERE sfs.EntityTypeId = 3 -- Customer entity
				AND sfs.EntityId = c.Id
				AND sfs.AccountId = sf.Id
				AND (c.ModifiedTimestamp <= sfs.LastSyncTimestamp
					OR sfs.RetryCount >= @MaxRetryCount)
			-- Entity is not Synced (e.g. no record in SalesforceSyncStatus) OR record is out of sync
				-- The timestamp check is inversed to return no results when it is out of sync
			)

	--Remove any accounts already flagged for sync
	DELETE af
	FROM #AccountsWithSalesforceEnabled af
	INNER JOIN #Accounts a ON a.Id = af.Id

	-- Accounts with out of sync subscription
	INSERT INTO #Accounts
	SELECT sf.Id
	FROM #AccountsWithSalesforceEnabled sf
	INNER JOIN Customer c ON sf.Id = c.AccountId
		AND c.SalesforceSynchStatusId = 1
		AND c.IsDeleted = 0
	INNER JOIN Subscription s ON c.Id = s.CustomerId
	WHERE 
		NOT EXISTS (
			SELECT * FROM SalesforceSyncStatus sfs
			WHERE sfs.EntityTypeId = 7 -- Subscription entity
			AND sfs.EntityId = s.Id
			AND sfs.AccountId = sf.Id
			AND (s.ModifiedTimestamp <= sfs.LastSyncTimestamp
				OR sfs.RetryCount >= @MaxRetryCount)
		)

	--Remove any accounts already flagged for sync
	DELETE af
	FROM #AccountsWithSalesforceEnabled af
	INNER JOIN #Accounts a ON a.Id = af.Id

	-- Accounts with out of sync purchase
	INSERT INTO #Accounts
	SELECT sf.Id
	FROM #AccountsWithSalesforceEnabled sf
	INNER JOIN Customer c ON sf.Id = c.AccountId
		AND c.SalesforceSynchStatusId = 1
		AND c.IsDeleted = 0
	INNER JOIN Purchase p ON c.Id = p.CustomerId
	WHERE 
		NOT EXISTS (
			SELECT * FROM SalesforceSyncStatus sfs
			WHERE sfs.EntityTypeId = 21 -- Purchase entity
			AND sfs.EntityId = p.Id
			AND sfs.AccountId = sf.Id
			AND (p.ModifiedTimestamp <= sfs.LastSyncTimestamp
				OR sfs.RetryCount >= @MaxRetryCount)
		)

	--Remove any accounts already flagged for sync
	DELETE af
	FROM #AccountsWithSalesforceEnabled af
	INNER JOIN #Accounts a ON a.Id = af.Id

	-- Accounts with out of sync invoices
	INSERT INTO #Accounts
	SELECT sf.Id
	FROM #AccountsWithSalesforceEnabled sf
	INNER JOIN Customer c ON sf.Id = c.AccountId
		AND c.SalesforceSynchStatusId = 1
		AND c.IsDeleted = 0
	INNER JOIN Invoice i ON c.Id = i.CustomerId
	INNER JOIN InvoiceJournal ij ON i.Id = ij.InvoiceId
		AND ij.IsActive = 1
	WHERE 
		NOT EXISTS (
			SELECT * FROM SalesforceSyncStatus sfs
			WHERE sfs.EntityTypeId = 11 -- Invoice entity
				AND sfs.EntityId = i.Id
				AND sfs.AccountId = sf.Id
				AND (ij.CreatedTimestamp <= sfs.LastSyncTimestamp
				OR sfs.RetryCount >= @MaxRetryCount)
		)

		--Remove any accounts already flagged for sync
	DELETE af
	FROM #AccountsWithSalesforceEnabled af
	INNER JOIN #Accounts a ON a.Id = af.Id

	 --Accounts with out of sync Subscription products
	SELECT sf.Id, sp.Id as 'SubscriptionProductId', sp.ModifiedTimestamp as 'SubscriptionProductModifiedTimestamp'
	INTO #AccountsAll
	FROM #AccountsWithSalesforceEnabled sf
	INNER JOIN Customer c ON sf.Id = c.AccountId
		AND c.SalesforceSynchStatusId = 1
		AND c.IsDeleted = 0
	INNER JOIN Subscription s ON c.Id = s.CustomerId
	INNER JOIN SubscriptionProduct sp ON s.Id = sp.SubscriptionId
	WHERE sf.MaintainSubscriptionProductsInSalesforce = 1
	--Need conditions here to handle All, IncludedOnly, None cases
	AND (
		(sf.SalesforceSubscriptionProductsSyncOptionId = 1) OR
		(sf.SalesforceSubscriptionProductsSyncOptionId = 2 AND (sp.Included = 1 OR sp.SalesforceId IS NOT NULL))
	)
	AND
		NOT EXISTS (
			SELECT * FROM SalesforceSyncStatus sfs
			WHERE sfs.EntityTypeId = 14 -- Subscription product entity
			AND sfs.EntityId = sp.Id
			AND sfs.AccountId = sf.Id
			AND (sp.ModifiedTimestamp <= sfs.LastSyncTimestamp
				OR sfs.RetryCount >= @MaxRetryCount)
		)


	SELECT DISTINCT Id FROM #Accounts
	UNION
	SELECT DISTINCT Id FROM #AccountsAll


	DROP TABLE #AccountsWithSalesforceEnabled
	DROP TABLE #Accounts
	DROP TABLE #AccountsAll


END

GO

