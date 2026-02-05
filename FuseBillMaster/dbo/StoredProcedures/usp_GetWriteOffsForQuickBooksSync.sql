CREATE   PROCEDURE [dbo].[usp_GetWriteOffsForQuickBooksSync]
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
		AND qb.WriteOffAccountRefId IS NOT NULL
		AND qb.WriteOffItemRefId IS NOT NULL
	INNER JOIN AccountFeatureConfiguration afc ON afc.Id = a.Id
		AND afc.QuickBooksEnabled = 1
	WHERE c.QuickBooksId IS NOT NULL
	AND a.IncludeInAutomatedProcesses = 1

	CREATE TABLE #BlockedRecords (
		AccountId BIGINT
		,CompanyName NVARCHAR(255)
		,WriteOffId BIGINT
		,InvoiceId BIGINT
		,InvoiceQBOId BIGINT
		,QuickBooksAttemptNumber INT
		)

	INSERT INTO #BlockedRecords (AccountId, CompanyName, WriteOffId, InvoiceId, InvoiceQBOId, QuickBooksAttemptNumber)
	SELECT 
		cts.AccountId
		,cts.CompanyName
		,w.Id AS WriteOffId
		,w.InvoiceId
		,i.QuickBooksId as InvoiceQBOId
		,i.QuickBooksAttemptNumber
	FROM #CustomersToSync cts
	INNER JOIN [Transaction] t ON t.CustomerId = cts.CustomerId 
		AND t.EffectiveTimestamp >= cts.QuickBooksSyncTimestamp
	INNER JOIN WriteOff w ON w.Id = t.Id
		AND w.QuickBooksId IS NULL
		AND w.QuickBooksAttemptNumber < 5
	INNER JOIN Invoice i on i.Id = w.InvoiceId

	UPDATE WriteOff SET IsQuickBooksBlock = 1 WHERE Id IN (
		SELECT WriteOffId FROM #BlockedRecords WHERE InvoiceQBOId IS NULL
	)
	
	UPDATE WriteOff SET IsQuickBooksBlock = NULL WHERE Id IN (
		SELECT WriteOffId FROM #BlockedRecords WHERE InvoiceQBOId IS NOT NULL
	)

	SELECT AccountId, CompanyName, WriteOffId FROM #BlockedRecords where InvoiceQBOId IS NOT NULL

	DROP TABLE #CustomersToSync
	DROP TABLE #BlockedRecords

END

GO

