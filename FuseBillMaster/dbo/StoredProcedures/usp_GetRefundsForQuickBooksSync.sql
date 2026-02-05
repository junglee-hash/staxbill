CREATE   PROCEDURE [dbo].[usp_GetRefundsForQuickBooksSync]
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

	CREATE TABLE #BlockedRecords (
		AccountId BIGINT
		,CompanyName NVARCHAR(255)
		,RefundId BIGINT
		,OriginalPaymentId BIGINT
		,PaymentQBOId BIGINT
		,QuickBooksAttemptNumber INT
		)
	
	INSERT INTO #BlockedRecords (AccountId, CompanyName, RefundId, OriginalPaymentId, PaymentQBOId, QuickBooksAttemptNumber)
	SELECT 
		cts.AccountId
		,cts.CompanyName
		,r.Id as RefundId
		,r.OriginalPaymentId
		,p.QuickBooksId as PaymentQBOId
		,p.QuickBooksAttemptNumber
	FROM #CustomersToSync cts
	INNER JOIN [Transaction] t ON t.CustomerId = cts.CustomerId 
		AND t.EffectiveTimestamp >= cts.QuickBooksSyncTimestamp
	INNER JOIN Refund r ON r.Id = t.Id
		AND r.QuickBooksId IS NULL
		AND r.QuickBooksAttemptNumber < 5
	INNER JOIN Payment p on p.Id = r.OriginalPaymentId
		AND p.SendToQuickbooksOnline = 1

	UPDATE Refund SET IsQuickBooksBlock = 1 WHERE Id IN (
		SELECT RefundId FROM #BlockedRecords WHERE PaymentQBOId IS NULL
	)
	
	UPDATE Debit SET IsQuickBooksBlock = NULL WHERE Id IN (
		SELECT RefundId FROM #BlockedRecords WHERE PaymentQBOId IS NOT NULL
	)

	SELECT AccountId, CompanyName, RefundId FROM #BlockedRecords where PaymentQBOId IS NOT NULL

	DROP TABLE #CustomersToSync
	DROP TABLE #BlockedRecords

END

GO

