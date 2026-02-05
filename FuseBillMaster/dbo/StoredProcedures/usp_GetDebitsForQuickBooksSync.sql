CREATE   PROCEDURE [dbo].[usp_GetDebitsForQuickBooksSync]
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
		AND qb.CreditAccountRefId IS NOT NULL
		AND qb.CreditItemRefId IS NOT NULL
	INNER JOIN AccountFeatureConfiguration afc ON afc.Id = a.Id
		AND afc.QuickBooksEnabled = 1
	WHERE c.QuickBooksId IS NOT NULL
	AND a.IncludeInAutomatedProcesses = 1

	CREATE TABLE #BlockedRecords (
		AccountId BIGINT
		,CompanyName NVARCHAR(255)
		,DebitId BIGINT
		,InvoiceId BIGINT
		,InvoiceQBOId BIGINT
		,QuickBooksAttemptNumber INT
		)
	
	INSERT INTO #BlockedRecords (AccountId, CompanyName, DebitId, InvoiceId, InvoiceQBOId, QuickBooksAttemptNumber)
	SELECT 
		cts.AccountId
		,cts.CompanyName
		,dr.Id AS DebitId
		,dr.OriginalCreditId
		,cr.QuickBooksId as InvoiceQBOId
		,cr.QuickBooksAttemptNumber
	FROM #CustomersToSync cts
	INNER JOIN [Transaction] t ON t.CustomerId = cts.CustomerId 
		AND t.EffectiveTimestamp >= cts.QuickBooksSyncTimestamp
	INNER JOIN Debit dr ON dr.Id = t.Id
		AND dr.QuickBooksId IS NULL
		AND dr.QuickBooksAttemptNumber < 5
	INNER JOIN Credit cr on cr.Id = dr.OriginalCreditId

	UPDATE Debit SET IsQuickBooksBlock = 1 WHERE Id IN (
		SELECT DebitId FROM #BlockedRecords WHERE InvoiceQBOId IS NULL
	)
	
	UPDATE Debit SET IsQuickBooksBlock = NULL WHERE Id IN (
		SELECT DebitId FROM #BlockedRecords WHERE InvoiceQBOId IS NOT NULL
	)

	SELECT AccountId, CompanyName, DebitId FROM #BlockedRecords where InvoiceQBOId IS NOT NULL

	DROP TABLE #CustomersToSync
	DROP TABLE #BlockedRecords

END

GO

