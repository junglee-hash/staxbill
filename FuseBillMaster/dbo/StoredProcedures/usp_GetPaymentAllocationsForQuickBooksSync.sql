CREATE   PROCEDURE [dbo].[usp_GetPaymentAllocationsForQuickBooksSync]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	CREATE TABLE #CustomersToSync (
		CustomerId BIGINT PRIMARY KEY CLUSTERED
		,QuickBooksSyncTimestamp DATETIME
		,AccountId BIGINT
		,CompanyName NVARCHAR(255))

	--Customers eligible to sync
	INSERT INTO #CustomersToSync (CustomerId,QuickBooksSyncTimestamp,AccountId,CompanyName)
	SELECT 
		c.Id AS CustomerId
		,c.QuickBooksSyncTimestamp
		,a.Id AS AccountId
		,a.CompanyName
	FROM Customer c
	INNER JOIN Account a ON a.Id = c.AccountId
	INNER JOIN AccountQuickBooksOnlineConfig qb ON qb.Id = a.Id
		AND qb.StatusId = 2
	INNER JOIN AccountFeatureConfiguration afc ON afc.Id = a.Id
		AND afc.QuickBooksEnabled = 1
	WHERE c.QuickBooksId IS NOT NULL
	AND a.IncludeInAutomatedProcesses = 1

	SELECT 
		cts.AccountId
		,cts.CompanyName
		,pn.Id as PaymentNoteId
	FROM #CustomersToSync cts
	INNER JOIN [Transaction] t ON t.CustomerId = cts.CustomerId 
		AND t.EffectiveTimestamp >= cts.QuickBooksSyncTimestamp
	INNER JOIN Payment p ON p.Id = t.Id 
		AND p.QuickBooksId IS NOT NULL
	INNER JOIN PaymentNote pn ON pn.PaymentId = p.Id 
		AND pn.SyncedToQuickBooks = 0
		AND pn.QuickBooksAttemptNumber < 5
	WHERE EXISTS (
		SELECT 1
		FROM Invoice i 
		WHERE i.Id = pn.InvoiceId
			AND i.QuickBooksId IS NOT NULL
		)

	DROP TABLE #CustomersToSync

END

GO

