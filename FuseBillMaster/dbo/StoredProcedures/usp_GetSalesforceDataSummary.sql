CREATE   PROCEDURE [dbo].[usp_GetSalesforceDataSummary]
	@AccountId bigint
	, @StartDate datetime 
	, @EndDate datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @MaxRetryCount int = 2

	DECLARE @SalesforceSubProductSyncOption TINYINT
	
	
	SELECT @SalesforceSubProductSyncOption = SalesforceSubscriptionProductsSyncOptionId FROM AccountSalesforceConfiguration WHERE Id = @AccountId

	-- Count of CUSTOMERS
	--Entity 3
    SELECT 
		COUNT(c.Id) as TotalCount
		, COUNT(
			CASE WHEN c.SalesforceId IS NULL 
			OR LEN(c.SalesforceId) = 0 
			OR sss.RetryCount >= @MaxRetryCount THEN NULL
			ELSE 1
			END) as SalesforceCount
		, COUNT(
			CASE WHEN nsw.Id IS NULL THEN NULL -- No ignore note
				WHEN nsw.Id IS NOT NULL AND c.SalesforceId IS NOT NULL AND LEN(c.SalesforceId) > 0 THEN NULL -- Ignore note but has a Salesforce ID
			ELSE 1
			END) as IgnoredCount
		, COUNT(
			CASE WHEN afc.SalesforceBulkSyncEnabled = 1 
				AND (sss.Id IS NULL 
					OR (sss.LastSyncTimestamp < c.ModifiedTimestamp AND sss.RetryCount < @MaxRetryCount)
				) AND c.SalesforceSynchStatusId = 1 THEN 1
			ELSE null
			END) as PendingSyncUpdate
			-- (Sync status ID is NULL OR last sync timestamp < entity's modified timestamp and retry count is less than max)
			-- and customer sf sync is enabled
			-- then 1
			-- else null
		, COUNT(
			CASE WHEN sss.RetryCount >= @MaxRetryCount THEN 1 ELSE NULL END
			) as ErrorCount
			,count(
				CASE WHEN (c.SalesforceId is null or LEN(c.SalesforceId) = 0) AND c.StatusId = 3
						THEN 1 ELSE null END
		) as FalseWarningCount
	FROM Customer c
	LEFT JOIN IntegrationIgnoredWarning nsw ON nsw.EntityTypeId = 3 -- Customer
			AND nsw.IntegrationTypeId = 1 -- Salesforce
			AND nsw.EntityId = c.Id
			AND nsw.AccountId = c.AccountId
	INNER JOIN AccountFeatureConfiguration afc ON afc.Id = c.AccountId
	left join [dbo].[SalesforceSyncStatus] sss on sss.EntityTypeId = 3 and sss.EntityId = c.Id
	WHERE c.AccountId = @AccountId
		AND c.ModifiedTimestamp >= @StartDate
		AND c.ModifiedTimestamp < @EndDate
		And c.IsDeleted = 0

	-- Count of INVOICES
	--Entity 11
	SELECT 
		COUNT(i.Id) as TotalCount
		, COUNT(
			CASE WHEN i.SalesforceId IS NULL OR LEN(i.SalesforceId) = 0 OR sss.RetryCount >= @MaxRetryCount THEN NULL
			ELSE 1
			END) as SalesforceCount
		, COUNT(
			CASE WHEN nsw.Id IS NULL THEN NULL -- No ignore note
				WHEN nsw.Id IS NOT NULL AND i.SalesforceId IS NOT NULL AND LEN(i.SalesforceId) > 0 THEN NULL -- Ignore note but has a Salesforce ID
			ELSE 1
			END) as IgnoredCount
		, COUNT(
			CASE WHEN afc.SalesforceBulkSyncEnabled = 1 
				AND (sss.Id IS NULL 
					OR (sss.LastSyncTimestamp < i.LastJournalTimestamp AND sss.RetryCount < @MaxRetryCount)
				) AND c.SalesforceSynchStatusId = 1 THEN 1
			ELSE null
			END) as PendingSyncUpdate
			-- (Sync status ID is NULL OR last sync timestamp < entity's modified timestamp and retry count is less than max)
			-- and customer sf sync is enabled
			-- then 1
			-- else null
		, COUNT(
			CASE WHEN sss.RetryCount >= @MaxRetryCount THEN 1 ELSE NULL END
			) as ErrorCount
			, 0 as FalseWarningCount
		FROM Invoice i
		INNER JOIN Customer c ON c.Id = i.CustomerId
		LEFT JOIN IntegrationIgnoredWarning nsw ON nsw.EntityTypeId = 11 -- Invoice
			AND nsw.IntegrationTypeId = 1 -- Salesforce
			AND nsw.EntityId = i.Id
			AND nsw.AccountId = c.AccountId
		INNER JOIN AccountFeatureConfiguration afc ON afc.Id = c.AccountId
		left join [dbo].[SalesforceSyncStatus] sss on sss.EntityTypeId = 11 and sss.EntityId = i.Id
		WHERE c.AccountId = @AccountId
			AND i.AccountId = @AccountId
			-- Exclude entities where the customer is not synced
			AND c.SalesforceId IS NOT NULL
			AND LEN(c.SalesforceId) > 0
			AND i.EffectiveTimestamp >= @StartDate
			AND i.EffectiveTimestamp < @EndDate
			AND c.IsDeleted = 0

	-- Count of Subscriptions
	--Entity 7
	SELECT 
		COUNT(s.Id) as TotalCount
		, COUNT(
			CASE WHEN s.SalesforceId IS NULL OR LEN(s.SalesforceId) = 0 OR sss.RetryCount >= @MaxRetryCount THEN NULL
			ELSE 1
			END) as SalesforceCount
		, COUNT(
			CASE WHEN nsw.Id IS NULL THEN NULL -- No ignore note
				WHEN nsw.Id IS NOT NULL AND s.SalesforceId IS NOT NULL AND LEN(s.SalesforceId) > 0 THEN NULL -- Ignore note but has a Salesforce ID
			ELSE 1
			END) as IgnoredCount
		, COUNT(
			CASE WHEN afc.SalesforceBulkSyncEnabled = 1 
				AND (sss.Id IS NULL 
					OR (sss.LastSyncTimestamp < s.ModifiedTimestamp AND sss.RetryCount < @MaxRetryCount)
				) AND c.SalesforceSynchStatusId = 1 THEN 1
			ELSE null
			END) as PendingSyncUpdate
			-- (Sync status ID is NULL OR last sync timestamp < entity's modified timestamp and retry count is less than max)
			-- and customer sf sync is enabled
			-- then 1
			-- else null
		, COUNT(
			CASE WHEN sss.RetryCount >= @MaxRetryCount THEN 1 ELSE NULL END
			) as ErrorCount
			, 0 as FalseWarningCount
		FROM Subscription s
		inner join Customer c on c.Id = s.CustomerId
		LEFT JOIN IntegrationIgnoredWarning nsw ON nsw.EntityTypeId = 7 -- Subscription
			AND nsw.IntegrationTypeId = 1 -- Salesforce
			AND nsw.EntityId = s.Id
			AND nsw.AccountId = c.AccountId
	INNER JOIN AccountFeatureConfiguration afc ON afc.Id = c.AccountId
		left join [dbo].[SalesforceSyncStatus] sss on sss.EntityTypeId = 7 and sss.EntityId = s.Id
		WHERE c.AccountId = @AccountId
			-- Exclude entities where the customer is not synced
			AND c.SalesforceId IS NOT NULL
			AND LEN(c.SalesforceId) > 0
		AND s.ModifiedTimestamp >= @StartDate
		AND s.ModifiedTimestamp < @EndDate
		And s.IsDeleted = 0
		AND c.IsDeleted = 0

	-- Count of Subscription Products
	-- Entity 14
	SELECT 
		COUNT(sp.Id) as TotalCount
		, COUNT(
			CASE WHEN sp.SalesforceId IS NULL OR LEN(sp.SalesforceId) = 0 OR sss.RetryCount >= @MaxRetryCount THEN NULL
			ELSE 1
			END) as SalesforceCount
		, COUNT(
			CASE WHEN nsw.Id IS NULL THEN NULL -- No ignore note
				WHEN nsw.Id IS NOT NULL AND sp.SalesforceId IS NOT NULL AND LEN(sp.SalesforceId) > 0 THEN NULL -- Ignore note but has a Salesforce ID
			ELSE 1
			END) as IgnoredCount
		,  COUNT(
			CASE WHEN afc.SalesforceBulkSyncEnabled = 1 
				AND (sss.Id IS NULL 
					OR (sss.LastSyncTimestamp < sp.ModifiedTimestamp AND sss.RetryCount < @MaxRetryCount)
				) AND c.SalesforceSynchStatusId = 1 THEN 1
			ELSE null
			END) as PendingSyncUpdate
			-- (Sync status ID is NULL OR last sync timestamp < entity's modified timestamp and retry count is less than max)
			-- and customer sf sync is enabled
			-- then 1
			-- else null
		, COUNT(
			CASE WHEN sss.RetryCount >= @MaxRetryCount THEN 1 ELSE NULL END
			) as ErrorCount
			, 0 as FalseWarningCount
		FROM SubscriptionProduct sp
		inner join Subscription s on s.Id = sp.SubscriptionId
		inner join Customer c on c.Id = s.CustomerId
		LEFT JOIN IntegrationIgnoredWarning nsw ON nsw.EntityTypeId = 14 -- Subscription Product
			AND nsw.IntegrationTypeId = 1 -- Salesforce
			AND nsw.EntityId = sp.Id
			AND nsw.AccountId = c.AccountId
	INNER JOIN AccountFeatureConfiguration afc ON afc.Id = c.AccountId
		left join [dbo].[SalesforceSyncStatus] sss on sss.EntityTypeId = 14 and sss.EntityId = sp.Id
		WHERE c.AccountId = @AccountId
			-- Exclude entities where the customer is not synced
			AND c.SalesforceId IS NOT NULL
			AND c.IsDeleted = 0
			AND LEN(c.SalesforceId) > 0
		AND sp.ModifiedTimestamp >= @StartDate
		AND sp.ModifiedTimestamp < @EndDate
		AND sp.Included = CASE WHEN @SalesforceSubProductSyncOption = 2 THEN 1 ELSE sp.Included END
		AND @SalesforceSubProductSyncOption != 3

	-- Count of Purchases
	-- Entity 21
	SELECT 
		COUNT(p.Id) as TotalCount
		, COUNT(
			CASE WHEN p.SalesforceId IS NULL OR LEN(p.SalesforceId) = 0 OR sss.RetryCount >= @MaxRetryCount THEN NULL
			ELSE 1
			END) as SalesforceCount
		, COUNT(
			CASE WHEN nsw.Id IS NULL THEN NULL -- No ignore note
				WHEN nsw.Id IS NOT NULL AND p.SalesforceId IS NOT NULL AND LEN(p.SalesforceId) > 0 THEN NULL -- Ignore note but has a Salesforce ID
			ELSE 1
			END) as IgnoredCount
		,  COUNT(
			CASE WHEN afc.SalesforceBulkSyncEnabled = 1 
				AND (sss.Id IS NULL 
					OR (sss.LastSyncTimestamp < p.ModifiedTimestamp AND sss.RetryCount < @MaxRetryCount)
				) AND c.SalesforceSynchStatusId = 1 THEN 1
			ELSE null
			END) as PendingSyncUpdate
			-- (Sync status ID is NULL OR last sync timestamp < entity's modified timestamp and retry count is less than max)
			-- and customer sf sync is enabled
			-- then 1
			-- else null
		, COUNT(
			CASE WHEN sss.RetryCount >= @MaxRetryCount THEN 1 ELSE NULL END
			) as ErrorCount
			, 0 as FalseWarningCount
		FROM Purchase p
		inner join Customer c on c.Id = p.CustomerId
		LEFT JOIN IntegrationIgnoredWarning nsw ON nsw.EntityTypeId = 21 -- Purchase
			AND nsw.IntegrationTypeId = 1 -- Salesforce
			AND nsw.EntityId = p.Id
			AND nsw.AccountId = c.AccountId
	INNER JOIN AccountFeatureConfiguration afc ON afc.Id = c.AccountId
		left join [dbo].[SalesforceSyncStatus] sss on sss.EntityTypeId = 21 and sss.EntityId = p.Id
		WHERE c.AccountId = @AccountId
			-- Exclude entities where the customer is not synced
			AND c.SalesforceId IS NOT NULL
			AND c.IsDeleted = 0
			AND p.IsDeleted = 0
			AND LEN(c.SalesforceId) > 0
		AND p.ModifiedTimestamp >= @StartDate
		AND p.ModifiedTimestamp < @EndDate

	-- Count of Product
	-- Entity 12
	SELECT 
		COUNT(p.Id) as TotalCount
		, COUNT(
			CASE WHEN p.SalesforceId IS NULL OR LEN(p.SalesforceId) = 0 THEN NULL
			ELSE 1
			END) as SalesforceCount
		, COUNT(
			CASE WHEN nsw.Id IS NULL THEN NULL -- No ignore note
				WHEN nsw.Id IS NOT NULL AND p.SalesforceId IS NOT NULL AND LEN(p.SalesforceId) > 0 THEN NULL -- Ignore note but has a Salesforce ID
			ELSE 1
			END) as IgnoredCount
		, 0 as PendingSyncUpdate
		, 0 as ErrorCount
		, 0 as FalseWarningCount
		FROM Product p
		LEFT JOIN IntegrationIgnoredWarning nsw ON nsw.EntityTypeId = 12 -- Product
			AND nsw.IntegrationTypeId = 1 -- Salesforce
			AND nsw.EntityId = p.Id
			AND nsw.AccountId = p.AccountId
		WHERE p.AccountId = @AccountId and p.ProductTypeId != 4 and p.ProductTypeId != 5
		AND p.ModifiedTimestamp >= @StartDate
		AND p.ModifiedTimestamp < @EndDate
	
	-- Count of Plan Frequencies
	-- Entity 101
	SELECT 
		COUNT(pf.Id) as TotalCount
		, COUNT(
			CASE WHEN pf.SalesforceId IS NULL OR LEN(pf.SalesforceId) = 0 THEN NULL
			ELSE 1
			END) as SalesforceCount
		, COUNT(
			CASE WHEN nsw.Id IS NULL THEN NULL -- No ignore note
				WHEN nsw.Id IS NOT NULL AND pf.SalesforceId IS NOT NULL AND LEN(pf.SalesforceId) > 0 THEN NULL -- Ignore note but has a Salesforce ID
			ELSE 1
			END) as IgnoredCount
		, 0 as PendingSyncUpdate
		, 0 as ErrorCount
		, 0 as FalseWarningCount
		FROM PlanFrequency pf
		inner join PlanRevision pr on pr.Id = pf.PlanRevisionId
		inner join [Plan] p on p.Id = pr.PlanId
		LEFT JOIN IntegrationIgnoredWarning nsw ON nsw.EntityTypeId = 101 -- Plan Frequency
			AND nsw.IntegrationTypeId = 1 -- Salesforce
			AND nsw.EntityId = pf.Id
			AND nsw.AccountId = p.AccountId
		WHERE p.AccountId = @AccountId
		AND p.ModifiedTimestamp >= @StartDate
		AND p.ModifiedTimestamp < @EndDate

END

GO

