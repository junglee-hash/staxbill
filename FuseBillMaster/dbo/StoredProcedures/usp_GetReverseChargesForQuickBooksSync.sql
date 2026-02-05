CREATE   PROCEDURE [dbo].[usp_GetReverseChargesForQuickBooksSync]
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
		AND NOT (afc.TaxOptionId <> 1 AND qb.TaxRecognitionOptionId = 1)
	WHERE c.QuickBooksId IS NOT NULL
	AND a.IncludeInAutomatedProcesses = 1

	CREATE TABLE #BlockedRecords (
		AccountId BIGINT
		,CompanyName NVARCHAR(255)
		,ReverseChargeId BIGINT
		,InvoiceId BIGINT
		,InvoiceQBOId BIGINT
		,QuickBooksAttemptNumber INT
		)
	
	INSERT INTO #BlockedRecords (AccountId, CompanyName, ReverseChargeId, InvoiceId, InvoiceQBOId, QuickBooksAttemptNumber)
	SELECT 
		cts.AccountId
		,cts.CompanyName
		,rc.Id as ReverseChargeId
		,ch.InvoiceId
		,i.QuickBooksId as InvoiceQBOId
		,i.QuickBooksAttemptNumber
	FROM #CustomersToSync cts
	INNER JOIN [Transaction] t ON t.CustomerId = cts.CustomerId 
		AND t.EffectiveTimestamp >= cts.QuickBooksSyncTimestamp
	INNER JOIN ReverseCharge rc ON rc.Id = t.Id
		AND rc.QuickBooksId IS NULL
		AND rc.QuickBooksAttemptNumber < 5
	INNER JOIN Charge ch ON ch.Id = rc.OriginalChargeId
	INNER JOIN Invoice i on i.Id = ch.InvoiceId

	UPDATE ReverseCharge SET IsQuickBooksBlock = 1 WHERE Id IN (
		SELECT ReverseChargeId FROM #BlockedRecords WHERE InvoiceQBOId IS NULL
	)
	
	UPDATE ReverseCharge SET IsQuickBooksBlock = NULL WHERE Id IN (
		SELECT ReverseChargeId FROM #BlockedRecords WHERE InvoiceQBOId IS NOT NULL
	)

	SELECT AccountId, CompanyName, ReverseChargeId FROM #BlockedRecords where InvoiceQBOId IS NOT NULL

	DROP TABLE #CustomersToSync
	DROP TABLE #BlockedRecords

END

GO

