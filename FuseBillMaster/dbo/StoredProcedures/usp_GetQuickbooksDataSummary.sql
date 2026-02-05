CREATE   PROCEDURE [dbo].[usp_GetQuickbooksDataSummary]
	@AccountId bigint
	, @StartDate datetime
	, @EndDate datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Count of CUSTOMERS
    SELECT 
		COUNT(c.Id) as TotalCount
		, COUNT(
			CASE WHEN c.QuickbooksId IS NULL OR LEN(c.QuickbooksId) = 0 THEN NULL
			ELSE 1
			END) as QuickbooksCount
		, COUNT(
			CASE WHEN nsw.Id IS NULL THEN NULL -- No ignore note
				WHEN nsw.Id IS NOT NULL AND c.QuickbooksId IS NOT NULL AND LEN(c.QuickbooksId) > 0 THEN NULL -- Ignore note but has a Quickbooks ID
			ELSE 1
			END) as IgnoredCount
			, 0 as PendingSyncUpdate
		, 0 as ErrorCount
			,count(
				CASE WHEN c.QuickBooksId is null AND c.StatusId = 3
						THEN 1 ELSE null END
		) as FalseWarningCount
	FROM Customer c
	LEFT JOIN IntegrationIgnoredWarning nsw ON nsw.EntityTypeId = 3 -- Customer
		AND nsw.IntegrationTypeId = 3 -- QuickBooks
		AND nsw.EntityId = c.Id
		AND nsw.AccountId = c.AccountId
	WHERE c.AccountId = @AccountId
		AND c.IsDeleted = 0

	-- Count of INVOICES
		-- Invoices created after customer sync timestamp with no Quickbooks ID
	SELECT 
		COUNT(i.Id) as TotalCount
		, COUNT(
			CASE WHEN i.QuickbooksId IS NULL OR LEN(i.QuickbooksId) = 0 THEN NULL
			ELSE 1
			END) as QuickbooksCount
		, COUNT(
			CASE WHEN nsw.Id IS NULL THEN NULL -- No ignore note
				WHEN nsw.Id IS NOT NULL AND i.QuickBooksId IS NOT NULL AND LEN(i.QuickBooksId) > 0 THEN NULL -- Ignore note but has a Quickbooks ID
			ELSE 1
			END) as IgnoredCount
			, 0 as PendingSyncUpdate
		, 0 as ErrorCount
			,0 as FalseWarningCount
		FROM Invoice i
		INNER JOIN Customer c ON c.Id = i.CustomerId
		LEFT JOIN IntegrationIgnoredWarning nsw ON nsw.EntityTypeId = 11 -- Invoice
			AND nsw.IntegrationTypeId = 3 -- QuickBooks
			AND nsw.EntityId = i.Id
			AND nsw.AccountId = i.AccountId
		WHERE c.AccountId = @AccountId
			AND i.AccountId = @AccountId
			AND i.EffectiveTimestamp >= CASE WHEN c.QuickbooksSyncTimestamp > @StartDate
				THEN c.QuickbooksSyncTimestamp ELSE @StartDate END
			AND i.EffectiveTimestamp < @EndDate
			AND c.QuickbooksId IS NOT NULL
			AND LEN(c.QuickbooksId) > 0
	
	--Filter down to just the transactions in the time range
	--Can exclude more transaction types if we want but charge and earning should be the noisiest
	SELECT
		t.Id
		,t.AccountId
		,t.CustomerId
		,t.EffectiveTimestamp
	INTO #TransactionsFiltered
	FROM [Transaction] t
	WHERE t.AccountId = @AccountId
	AND t.EffectiveTimestamp >= @StartDate
	AND t.EffectiveTimestamp < @EndDate
	AND t.TransactionTypeId NOT IN (1,6)

	-- Count of PAYMENTS
		-- Payments created after customer sync timestamp with no Quickbooks ID
	SELECT
		COUNT(p.Id) as TotalCount
		, COUNT(
			CASE WHEN p.QuickbooksId IS NULL OR LEN(p.QuickbooksId) = 0 THEN NULL
			ELSE 1
			END) as QuickbooksCount
		, COUNT(
			CASE WHEN nsw.Id IS NULL THEN NULL -- No ignore note
				WHEN nsw.Id IS NOT NULL AND p.QuickBooksId IS NOT NULL AND LEN(p.QuickBooksId) > 0 THEN NULL -- Ignore note but has a Quickbooks ID
			ELSE 1
			END) as IgnoredCount
			, 0 as PendingSyncUpdate
		, 0 as ErrorCount
			,0 as FalseWarningCount
		FROM Payment p
		INNER JOIN #TransactionsFiltered t ON t.Id = p.Id
		INNER JOIN Customer c ON c.Id = t.CustomerId
		LEFT JOIN IntegrationIgnoredWarning nsw ON nsw.EntityTypeId = 40 -- Payment
		AND nsw.IntegrationTypeId = 3 -- QuickBooks
			AND nsw.EntityId = t.Id
			AND nsw.AccountId = t.AccountId
		WHERE c.AccountId = @AccountId
			AND t.AccountId = @AccountId
			and p.SendToQuickbooksOnline = 1
			AND t.EffectiveTimestamp >= CASE WHEN c.QuickbooksSyncTimestamp > @StartDate
				THEN c.QuickbooksSyncTimestamp ELSE @StartDate END
			AND t.EffectiveTimestamp < @EndDate
			AND c.QuickbooksId IS NOT NULL
			AND LEN(c.QuickbooksId) > 0

	-- Count of REFUNDS
		-- Refunds associated to payment with a Quickbooks ID where refund has no Quickbooks ID
	SELECT
		COUNT(r.Id) as TotalCount
		, COUNT(
			CASE WHEN r.QuickbooksId IS NULL OR LEN(r.QuickbooksId) = 0 THEN NULL
			ELSE 1
			END) as QuickbooksCount
		, COUNT(
			CASE WHEN nsw.Id IS NULL THEN NULL -- No ignore note
				WHEN nsw.Id IS NOT NULL AND r.QuickBooksId IS NOT NULL AND LEN(r.QuickBooksId) > 0 THEN NULL -- Ignore note but has a Quickbooks ID
			ELSE 1
			END) as IgnoredCount
			, 0 as PendingSyncUpdate
		, 0 as ErrorCount
			,0 as FalseWarningCount
	FROM Refund r
	INNER JOIN #TransactionsFiltered t ON t.Id = r.Id
		INNER JOIN Customer c ON c.Id = t.CustomerId
		inner join Payment p on p.Id = r.OriginalPaymentId
		LEFT JOIN IntegrationIgnoredWarning nsw ON nsw.EntityTypeId = 81 -- Refund
		AND nsw.IntegrationTypeId = 3 -- QuickBooks
			AND nsw.EntityId = t.Id
			AND nsw.AccountId = t.AccountId
		WHERE c.AccountId = @AccountId
			AND t.AccountId = @AccountId
			and p.SendToQuickbooksOnline = 1
			AND t.EffectiveTimestamp >= CASE WHEN c.QuickbooksSyncTimestamp > @StartDate
				THEN c.QuickbooksSyncTimestamp ELSE @StartDate END
			AND t.EffectiveTimestamp < @EndDate
			AND c.QuickbooksId IS NOT NULL
			AND LEN(c.QuickbooksId) > 0

	-- Count of CREDITS
		-- Credits created after customer sync timestamp with no Quickbooks ID
	SELECT
		COUNT(cr.Id) as TotalCount
		, COUNT(
			CASE WHEN cr.QuickbooksId IS NULL OR LEN(cr.QuickbooksId) = 0 THEN NULL
			ELSE 1
			END) as QuickbooksCount
		, COUNT(
			CASE WHEN nsw.Id IS NULL THEN NULL -- No ignore note
				WHEN nsw.Id IS NOT NULL AND cr.QuickBooksId IS NOT NULL AND LEN(cr.QuickBooksId) > 0 THEN NULL -- Ignore note but has a Quickbooks ID
			ELSE 1
			END) as IgnoredCount
			, 0 as PendingSyncUpdate
		, 0 as ErrorCount
			,0 as FalseWarningCount
		FROM Credit cr
		INNER JOIN #TransactionsFiltered t ON t.Id = cr.Id
		INNER JOIN Customer c ON c.Id = t.CustomerId
		LEFT JOIN IntegrationIgnoredWarning nsw ON nsw.EntityTypeId = 82 -- Credit
		AND nsw.IntegrationTypeId = 3 -- QuickBooks
			AND nsw.EntityId = t.Id
			AND nsw.AccountId = t.AccountId
		WHERE c.AccountId = @AccountId
			AND t.AccountId = @AccountId
			AND t.EffectiveTimestamp >= CASE WHEN c.QuickbooksSyncTimestamp > @StartDate
				THEN c.QuickbooksSyncTimestamp ELSE @StartDate END
			AND t.EffectiveTimestamp < @EndDate
			AND c.QuickbooksId IS NOT NULL
			AND LEN(c.QuickbooksId) > 0

	-- Count of DEBITS
		-- Debits associated to credit with a Quickbooks ID where debit has no Quickbooks ID
	SELECT
		COUNT(d.Id) as TotalCount
		, COUNT(
			CASE WHEN d.QuickbooksId IS NULL OR LEN(d.QuickbooksId) = 0 THEN NULL
			ELSE 1
			END) as QuickbooksCount
		, COUNT(
			CASE WHEN nsw.Id IS NULL THEN NULL -- No ignore note
				WHEN nsw.Id IS NOT NULL AND d.QuickBooksId IS NOT NULL AND LEN(d.QuickBooksId) > 0 THEN NULL -- Ignore note but has a Quickbooks ID
			ELSE 1
			END) as IgnoredCount
			, 0 as PendingSyncUpdate
		, 0 as ErrorCount
			,0 as FalseWarningCount
	FROM Debit d
	INNER JOIN #TransactionsFiltered t ON t.Id = d.Id
		INNER JOIN Customer c ON c.Id = t.CustomerId
		LEFT JOIN IntegrationIgnoredWarning nsw ON nsw.EntityTypeId = 83 -- Debit
		AND nsw.IntegrationTypeId = 3 -- QuickBooks
			AND nsw.EntityId = t.Id
			AND nsw.AccountId = t.AccountId
		WHERE c.AccountId = @AccountId
			AND t.AccountId = @AccountId
			AND t.EffectiveTimestamp >= CASE WHEN c.QuickbooksSyncTimestamp > @StartDate
				THEN c.QuickbooksSyncTimestamp ELSE @StartDate END
			AND t.EffectiveTimestamp < @EndDate
			AND c.QuickbooksId IS NOT NULL
			AND LEN(c.QuickbooksId) > 0

	-- Count of REVERSE CHARGES
		-- Credit note groups associated to an invoice that has a Quickbooks ID and CNG has no Quickbooks ID
	SELECT
		COUNT(rc.Id) as TotalCount
		, COUNT(
			CASE WHEN rc.QuickbooksId IS NULL OR LEN(rc.QuickbooksId) = 0 THEN NULL
			ELSE 1
			END) as QuickbooksCount
		, COUNT(
			CASE WHEN nsw.Id IS NULL THEN NULL -- No ignore note
				WHEN nsw.Id IS NOT NULL AND rc.QuickBooksId IS NOT NULL AND LEN(rc.QuickBooksId) > 0 THEN NULL -- Ignore note but has a Quickbooks ID
			ELSE 1
			END) as IgnoredCount
			, 0 as PendingSyncUpdate
		, 0 as ErrorCount
			,0 as FalseWarningCount
	FROM ReverseCharge rc
	INNER JOIN #TransactionsFiltered t ON t.Id = rc.Id
		INNER JOIN Customer c ON c.Id = t.CustomerId
		LEFT JOIN IntegrationIgnoredWarning nsw ON nsw.EntityTypeId = 84 -- Reverse Charge
		AND nsw.IntegrationTypeId = 3 -- QuickBooks
			AND nsw.EntityId = rc.Id
			AND nsw.AccountId = t.AccountId
		WHERE c.AccountId = @AccountId
			AND t.AccountId = @AccountId
			AND t.EffectiveTimestamp >= CASE WHEN c.QuickbooksSyncTimestamp > @StartDate
				THEN c.QuickbooksSyncTimestamp ELSE @StartDate END
			AND t.EffectiveTimestamp < @EndDate
			AND c.QuickbooksId IS NOT NULL
			AND LEN(c.QuickbooksId) > 0

	-- Count of WRITE OFFS
		-- Write offs associated to an invoice that has a Quickbooks ID and Write off has no Quickbooks ID
	SELECT
		COUNT(w.Id) as TotalCount
		, COUNT(
			CASE WHEN w.QuickbooksId IS NULL OR LEN(w.QuickbooksId) = 0 THEN NULL
			ELSE 1
			END) as QuickbooksCount
		, COUNT(
			CASE WHEN nsw.Id IS NULL THEN NULL -- No ignore note
				WHEN nsw.Id IS NOT NULL AND w.QuickBooksId IS NOT NULL AND LEN(w.QuickBooksId) > 0 THEN NULL -- Ignore note but has a Quickbooks ID
			ELSE 1
			END) as IgnoredCount
			, 0 as PendingSyncUpdate
		, 0 as ErrorCount
			,0 as FalseWarningCount
	FROM WriteOff w
	INNER JOIN Invoice i ON i.Id = w.InvoiceId
	INNER JOIN Customer c ON c.Id = i.CustomerId
		LEFT JOIN IntegrationIgnoredWarning nsw ON nsw.EntityTypeId = 85 -- Write Off
		AND nsw.IntegrationTypeId = 3 -- QuickBooks
			AND nsw.EntityId = w.Id
			AND nsw.AccountId = i.AccountId
	WHERE c.AccountId = @AccountId
			AND i.AccountId = @AccountId
			AND i.EffectiveTimestamp >= CASE WHEN c.QuickbooksSyncTimestamp > @StartDate
				THEN c.QuickbooksSyncTimestamp ELSE @StartDate END
			AND i.EffectiveTimestamp < @EndDate
			AND c.QuickbooksId IS NOT NULL
			AND LEN(c.QuickbooksId) > 0

	-- Count of VOID REVERSE CHARGES
		-- Credit note groups associated to an invoice that has a Quickbooks ID and CNG has no Quickbooks ID
	SELECT
		COUNT(vrc.Id) as TotalCount
		, COUNT(
			CASE WHEN vrc.QuickbooksId IS NULL OR LEN(vrc.QuickbooksId) = 0 THEN NULL
			ELSE 1
			END) as QuickbooksCount
		, COUNT(
			CASE WHEN nsw.Id IS NULL THEN NULL -- No ignore note
				WHEN nsw.Id IS NOT NULL AND vrc.QuickBooksId IS NOT NULL AND LEN(vrc.QuickBooksId) > 0 THEN NULL -- Ignore note but has a Quickbooks ID
			ELSE 1
			END) as IgnoredCount
			, 0 as PendingSyncUpdate
		, 0 as ErrorCount
			,0 as FalseWarningCount
	FROM VoidReverseCharge vrc
	INNER JOIN ReverseCharge rc ON rc.Id = vrc.OriginalReverseChargeId
	INNER JOIN #TransactionsFiltered t ON t.Id = vrc.Id
		INNER JOIN Customer c ON c.Id = t.CustomerId
		LEFT JOIN IntegrationIgnoredWarning nsw ON nsw.EntityTypeId = 118 -- Void Reverse Charge
		AND nsw.IntegrationTypeId = 3 -- QuickBooks
			AND nsw.EntityId = vrc.Id
			AND nsw.AccountId = t.AccountId
		WHERE c.AccountId = @AccountId
			AND t.AccountId = @AccountId
			AND t.EffectiveTimestamp >= CASE WHEN c.QuickbooksSyncTimestamp > @StartDate
				THEN c.QuickbooksSyncTimestamp ELSE @StartDate END
			AND t.EffectiveTimestamp < @EndDate
			AND c.QuickbooksId IS NOT NULL
			AND LEN(c.QuickbooksId) > 0

	DROP TABLE #TransactionsFiltered
END

GO

