
CREATE       PROCEDURE [dbo].[usp_GetNetsuiteDataSummary]
	@AccountId bigint
	, @StartDate datetime
	, @EndDate datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @UseRefundTransaction BIT
	SELECT @UseRefundTransaction = UseRefundTransaction
	FROM AccountNetsuiteConfiguration
	WHERE Id = @AccountId

	-- Count of CUSTOMERS
    SELECT
		COUNT(c.Id) as TotalCount
		, COUNT(
			CASE WHEN c.NetsuiteId IS NULL OR LEN(c.NetsuiteId) = 0 THEN NULL
			ELSE 1
			END) as NetsuiteCount
		, COUNT(
			CASE WHEN nsw.Id IS NULL THEN NULL -- No ignore note
				WHEN nsw.Id IS NOT NULL AND c.NetsuiteId IS NOT NULL AND LEN(c.NetsuiteId) > 0 THEN NULL -- Ignore note but has a NetSuite ID
			ELSE 1
			END) as IgnoredCount
			, 0 as PendingSyncUpdate
		, 0 as ErrorCount
		,count(
				CASE WHEN (c.NetsuiteId is null or LEN(c.NetsuiteId) = 0) AND c.StatusId = 3
						THEN 1 ELSE null END
		) as FalseWarningCount
	FROM Customer c
	LEFT JOIN IntegrationIgnoredWarning nsw ON nsw.EntityTypeId = 3 -- Customer
		AND nsw.IntegrationTypeId = 2 -- NetSuite
		AND nsw.EntityId = c.Id
		AND nsw.AccountId = c.AccountId
	WHERE c.AccountId = @AccountId
	------ CUSTOMER DOES NOT FILTER BY DATE AS IT IS ALWAYS ALL-TIME

	-- Count of INVOICES
		-- Invoices created after customer sync timestamp with no Netsuite ID
	SELECT
		COUNT(i.Id) as TotalCount
		, COUNT(
			CASE WHEN i.ErpNetsuiteId IS NULL OR LEN(i.ErpNetsuiteId) = 0 THEN NULL
			ELSE 1
			END) as NetsuiteCount
		, COUNT(
			CASE WHEN nsw.Id IS NULL THEN NULL -- No ignore note
				WHEN nsw.Id IS NOT NULL AND i.ErpNetsuiteId IS NOT NULL AND LEN(i.ErpNetsuiteId) > 0 THEN NULL -- Ignore note but has a NetSuite ID
			ELSE 1
			END) as IgnoredCount
			, 0 as PendingSyncUpdate
		, 0 as ErrorCount
			,0 as FalseWarningCount
		FROM Invoice i
		INNER JOIN Customer c ON c.Id = i.CustomerId
		LEFT JOIN IntegrationIgnoredWarning nsw ON nsw.EntityTypeId = 11 -- Invoice
			AND nsw.IntegrationTypeId = 2 -- NetSuite
			AND nsw.EntityId = i.Id
			AND nsw.AccountId = i.AccountId
		WHERE c.AccountId = @AccountId
			AND i.AccountId = @AccountId --helps leverage a really good index
			AND c.NetsuiteId IS NOT NULL
			AND LEN(c.NetsuiteId) > 0
			AND i.EffectiveTimestamp >= CASE WHEN c.NetsuiteSyncTimestamp > @StartDate
				THEN c.NetsuiteSyncTimestamp ELSE @StartDate END
			AND i.EffectiveTimestamp < @EndDate

	-- Count of PAYMENTS
		-- Payments created after customer sync timestamp with no Netsuite ID
		-- Fully refunded payments are deleted if not using refund transactions
	SELECT
		COUNT(p.Id) as TotalCount
		, COUNT(
			CASE WHEN p.NetsuiteId IS NULL OR LEN(p.NetsuiteId) = 0 THEN NULL
			ELSE 1
			END) as NetsuiteCount
		, COUNT(
			CASE WHEN nsw.Id IS NULL THEN NULL -- No ignore note
				WHEN nsw.Id IS NOT NULL AND p.NetsuiteId IS NOT NULL AND LEN(p.NetsuiteId) > 0 THEN NULL -- Ignore note but has a NetSuite ID
			ELSE 1
			END) as IgnoredCount
			, 0 as PendingSyncUpdate
		, 0 as ErrorCount
			,COUNT(
				-- False warning when refundable amount is 0 but has not been manually ignore
				-- and doesn't still have a Netsuite ID (It's possible that something has no refundable amount but still exists in Netsuite)
				CASE WHEN @UseRefundTransaction = 0 AND p.RefundableAmount = 0 
					AND nsw.Id IS NULL  AND (p.NetsuiteId IS NULL OR LEN(p.NetsuiteId) = 0)
						THEN 1 ELSE NULL END) as FalseWarningCount
		FROM Payment p
		INNER JOIN [Transaction] t ON t.Id = p.Id
		INNER JOIN Customer c ON c.Id = t.CustomerId
		LEFT JOIN IntegrationIgnoredWarning nsw ON nsw.EntityTypeId = 40 -- Payment
		AND nsw.IntegrationTypeId = 2 -- NetSuite
			AND nsw.EntityId = t.Id
			AND nsw.AccountId = t.AccountId
		WHERE c.AccountId = @AccountId
			AND t.AccountId = @AccountId
			AND p.SendToNetsuite = 1
			AND c.NetsuiteId IS NOT NULL
			AND LEN(c.NetsuiteId) > 0
			AND t.EffectiveTimestamp >= CASE WHEN c.NetsuiteSyncTimestamp > @StartDate
				THEN c.NetsuiteSyncTimestamp ELSE @StartDate END
			AND t.EffectiveTimestamp < @EndDate

	-- Count of REFUNDS
		-- Refunds associated to payment with a Netsuite ID where refund has no Netsuite ID
	SELECT
		COUNT(r.Id) as TotalCount
		, COUNT(
			CASE WHEN r.NetsuiteId IS NULL OR LEN(r.NetsuiteId) = 0 THEN NULL
			ELSE 1
			END) as NetsuiteCount
		, COUNT(
			CASE WHEN nsw.Id IS NULL THEN NULL -- No ignore note
				WHEN nsw.Id IS NOT NULL AND r.NetsuiteId IS NOT NULL AND LEN(r.NetsuiteId) > 0 THEN NULL -- Ignore note but has a NetSuite ID
			ELSE 1
			END) as IgnoredCount
			, 0 as PendingSyncUpdate
		, 0 as ErrorCount
			,COUNT(
				-- False warning when refundable amount is 0 but has not been manually ignore
				-- and doesn't still have a Netsuite ID (It's possible that something has no refundable amount but still exists in Netsuite)
				CASE WHEN @UseRefundTransaction = 0 AND p.RefundableAmount = 0 
					AND nsw.Id IS NULL AND (p.NetsuiteId IS NULL OR LEN(p.NetsuiteId) = 0)
						THEN 1 ELSE NULL END) as FalseWarningCount
	FROM Refund r
	INNER JOIN [Transaction] t ON t.Id = r.Id
		INNER JOIN Customer c ON c.Id = t.CustomerId
		INNER JOIN Payment p ON p.Id = r.OriginalPaymentId
		LEFT JOIN IntegrationIgnoredWarning nsw ON nsw.EntityTypeId = 81 -- Refund
		AND nsw.IntegrationTypeId = 2 -- NetSuite
			AND nsw.EntityId = t.Id
			AND nsw.AccountId = t.AccountId
		WHERE c.AccountId = @AccountId
			AND t.AccountId = @AccountId
			and p.SendToNetsuite = 1
			AND c.NetsuiteId IS NOT NULL
			AND LEN(c.NetsuiteId) > 0
			AND t.EffectiveTimestamp >= CASE WHEN c.NetsuiteSyncTimestamp > @StartDate
				THEN c.NetsuiteSyncTimestamp ELSE @StartDate END
			AND t.EffectiveTimestamp < @EndDate

	-- Count of CREDITS
		-- Credits created after customer sync timestamp with no Netsuite ID
		-- Fully reversed credits are deleted in Netsuite and should have no Netsuite ID
	SELECT
		COUNT(cr.Id) as TotalCount
		, COUNT(
			CASE WHEN cr.NetsuiteId IS NULL OR LEN(cr.NetsuiteId) = 0 THEN NULL
			ELSE 1
			END) as NetsuiteCount
		, COUNT(
			CASE WHEN nsw.Id IS NULL THEN NULL -- No ignore note
				WHEN nsw.Id IS NOT NULL AND cr.NetsuiteId IS NOT NULL AND LEN(cr.NetsuiteId) > 0 THEN NULL -- Ignore note but has a NetSuite ID
			ELSE 1
			END) as IgnoredCount
			, 0 as PendingSyncUpdate
		, 0 as ErrorCount
			-- False warning when refundable amount is 0 but has not been manually ignore
				-- and doesn't still have a Netsuite ID (It's possible that something has no refundable amount but still exists in Netsuite)
			,COUNT(CASE WHEN cr.ReversableAmount = 0 
				AND nsw.Id IS NULL  AND (cr.NetsuiteId IS NULL OR LEN(cr.NetsuiteId) = 0)
					THEN 1 ELSE NULL END) as FalseWarningCount
		FROM Credit cr
		INNER JOIN [Transaction] t ON t.Id = cr.Id
		INNER JOIN Customer c ON c.Id = t.CustomerId
		LEFT JOIN IntegrationIgnoredWarning nsw ON nsw.EntityTypeId = 82 -- Credit
		AND nsw.IntegrationTypeId = 2 -- NetSuite
			AND nsw.EntityId = t.Id
			AND nsw.AccountId = t.AccountId
		WHERE c.AccountId = @AccountId
			AND t.AccountId = @AccountId
			AND c.NetsuiteId IS NOT NULL
			AND LEN(c.NetsuiteId) > 0
			AND t.EffectiveTimestamp >= CASE WHEN c.NetsuiteSyncTimestamp > @StartDate
				THEN c.NetsuiteSyncTimestamp ELSE @StartDate END
			AND t.EffectiveTimestamp < @EndDate

	-- Count of DEBITS
		-- Debits associated to credit with a Netsuite ID where debit has no Netsuite ID
		-- Fully reversed credits are deleted in Netsuite and should have no Netsuite ID
	SELECT
		COUNT(d.Id) as TotalCount
		, COUNT(
			CASE WHEN d.NetsuiteId IS NULL OR LEN(d.NetsuiteId) = 0 THEN NULL
			ELSE 1
			END) as NetsuiteCount
		, COUNT(
			CASE WHEN nsw.Id IS NULL THEN NULL -- No ignore note
				WHEN nsw.Id IS NOT NULL AND d.NetsuiteId IS NOT NULL AND LEN(d.NetsuiteId) > 0 THEN NULL -- Ignore note but has a NetSuite ID
			ELSE 1
			END) as IgnoredCount
			, 0 as PendingSyncUpdate
		, 0 as ErrorCount
		-- False warning when refundable amount is 0 but has not been manually ignore
				-- and doesn't still have a Netsuite ID (It's possible that something has no refundable amount but still exists in Netsuite)
			,COUNT(CASE WHEN cr.ReversableAmount = 0 
				AND nsw.Id IS NULL  AND (d.NetsuiteId IS NULL OR LEN(d.NetsuiteId) = 0)
					THEN 1 ELSE NULL END) as FalseWarningCount
	FROM Debit d
	INNER JOIN [Transaction] t ON t.Id = d.Id
		INNER JOIN Customer c ON c.Id = t.CustomerId
		INNER JOIN Credit cr ON cr.Id = d.OriginalCreditId
		LEFT JOIN IntegrationIgnoredWarning nsw ON nsw.EntityTypeId = 83 -- Debit
		AND nsw.IntegrationTypeId = 2 -- NetSuite
			AND nsw.EntityId = t.Id
			AND nsw.AccountId = t.AccountId
		WHERE c.AccountId = @AccountId
			AND t.AccountId = @AccountId
			AND c.NetsuiteId IS NOT NULL
			AND LEN(c.NetsuiteId) > 0
			AND t.EffectiveTimestamp >= CASE WHEN c.NetsuiteSyncTimestamp > @StartDate
				THEN c.NetsuiteSyncTimestamp ELSE @StartDate END
			AND t.EffectiveTimestamp < @EndDate

	-- Count of REVERSE CHARGES
		-- Credit note groups associated to an invoice that has a Netsuite ID and CNG has no Netsuite ID
	;WITH CTE AS(
		SELECT 
			MAX(t.Effectivetimestamp) as EffectiveTimestamp,
			cng.Id as CreditNoteGroupId,
			cng.NetsuiteId,
			cng.InvoiceId
		FROM ReverseCharge rc
		INNER JOIN dbo.[Transaction] t on t.Id = rc.Id
		INNER JOIN CreditNote cn on cn.Id = rc.CreditNoteId
		INNER JOIN CreditNoteGroup cng on cng.Id = cn.CreditNoteGroupId
		GROUP BY cng.Id, NetsuiteId, cng.InvoiceId
	)
	SELECT
		COUNT(cng.CreditNoteGroupId) as TotalCount
		, COUNT(
			CASE WHEN cng.NetsuiteId IS NULL OR LEN(cng.NetsuiteId) = 0 THEN NULL
			ELSE 1
			END) as NetsuiteCount
		, COUNT(
			CASE WHEN nsw.Id IS NULL THEN NULL -- No ignore note
				WHEN nsw.Id IS NOT NULL AND cng.NetsuiteId IS NOT NULL AND LEN(cng.NetsuiteId) > 0 THEN NULL -- Ignore note but has a NetSuite ID
			ELSE 1
			END) as IgnoredCount
			, 0 as PendingSyncUpdate
		, 0 as ErrorCount
			,0 as FalseWarningCount
	FROM CTE cng
	INNER JOIN Invoice i ON i.Id = cng.InvoiceId
	INNER JOIN Customer c ON c.Id = i.CustomerId
		LEFT JOIN IntegrationIgnoredWarning nsw ON nsw.EntityTypeId = 84 -- Reverse Charge
		AND nsw.IntegrationTypeId = 2 -- NetSuite
			AND nsw.EntityId = cng.CreditNoteGroupId
			AND nsw.AccountId = i.AccountId
	WHERE c.AccountId = @AccountId
			AND i.AccountId = @AccountId
			AND c.NetsuiteId IS NOT NULL
			AND LEN(c.NetsuiteId) > 0
			AND i.EffectiveTimestamp > c.NetsuiteSyncTimestamp
			AND cng.EffectiveTimestamp >= CASE WHEN c.NetsuiteSyncTimestamp > @StartDate
				THEN c.NetsuiteSyncTimestamp ELSE @StartDate END
			AND cng.EffectiveTimestamp < @EndDate

	-- Count of WRITE OFFS
		-- Write offs associated to an invoice that has a Netsuite ID and Write off has no Netsuite ID
	SELECT
		COUNT(w.Id) as TotalCount
		, COUNT(
			CASE WHEN w.NetsuiteId IS NULL OR LEN(w.NetsuiteId) = 0 THEN NULL
			ELSE 1
			END) as NetsuiteCount
		, COUNT(
			CASE WHEN nsw.Id IS NULL THEN NULL -- No ignore note
				WHEN nsw.Id IS NOT NULL AND w.NetsuiteId IS NOT NULL AND LEN(w.NetsuiteId) > 0 THEN NULL -- Ignore note but has a NetSuite ID
			ELSE 1
			END) as IgnoredCount
			, 0 as PendingSyncUpdate
		, 0 as ErrorCount
			,0 as FalseWarningCount
	FROM WriteOff w
	INNER JOIN Invoice i ON i.Id = w.InvoiceId
	INNER JOIN Customer c ON c.Id = i.CustomerId
		LEFT JOIN IntegrationIgnoredWarning nsw ON nsw.EntityTypeId = 85 -- Write Off
		AND nsw.IntegrationTypeId = 2 -- NetSuite
			AND nsw.EntityId = w.Id
			AND nsw.AccountId = i.AccountId
	WHERE c.AccountId = @AccountId
			AND i.AccountId = @AccountId
			AND i.EffectiveTimestamp >= c.NetsuiteSyncTimestamp
			AND c.NetsuiteId IS NOT NULL
			AND LEN(c.NetsuiteId) > 0
			AND i.EffectiveTimestamp >= CASE WHEN c.NetsuiteSyncTimestamp > @StartDate
				THEN c.NetsuiteSyncTimestamp ELSE @StartDate END
			AND i.EffectiveTimestamp < @EndDate
END

GO

