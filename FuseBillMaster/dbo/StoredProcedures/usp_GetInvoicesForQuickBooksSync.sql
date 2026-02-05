CREATE   PROCEDURE [dbo].[usp_GetInvoicesForQuickBooksSync]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--The approach of filtering Invoices by AccountId rather than CustomerId (as done in the other sync procs) performs better in Prod 
	--This is due to the bias of invoices towards a small number of large AccountIds
	--See STORY 27217 for more details
	CREATE TABLE #AccountsToSync (
		AccountId BIGINT PRIMARY KEY CLUSTERED
		,CompanyName NVARCHAR(255))

	CREATE TABLE #InvoicesOfInterest (
		InvoiceId BIGINT PRIMARY KEY CLUSTERED
		,CompanyName NVARCHAR(255)
		,AccountId BIGINT)

	--Accounts eligible to sync
	INSERT INTO #AccountsToSync (AccountId,CompanyName)
	SELECT 
		a.Id AS AccountId
		,a.CompanyName
	FROM Account a
	INNER JOIN AccountQuickBooksOnlineConfig qb ON qb.Id = a.Id
		AND qb.StatusId = 2
	INNER JOIN AccountFeatureConfiguration afc ON afc.Id = a.Id
		AND afc.QuickBooksEnabled = 1
		AND NOT (afc.TaxOptionId <> 1 AND qb.TaxRecognitionOptionId = 1)
	WHERE a.IncludeInAutomatedProcesses = 1

		INSERT INTO #InvoicesOfInterest (InvoiceId,CompanyName,AccountId)
	SELECT 
		i.Id AS InvoiceId
		,ats.CompanyName
		,ats.AccountId
	FROM #AccountsToSync ats
	INNER JOIN Invoice i ON i.AccountId = ats.AccountId
	INNER JOIN Customer c ON c.Id = i.CustomerId
	WHERE c.QuickBooksId IS NOT NULL
		AND i.EffectiveTimestamp >= c.QuickBooksSyncTimestamp

	SELECT
		ii.AccountId
		,ii.CompanyName
		,ii.InvoiceId
	FROM #InvoicesOfInterest ii
	INNER JOIN Invoice i ON i.Id = ii.InvoiceId
	WHERE i.QuickBooksId IS NULL
		AND i.QuickBooksAttemptNumber < 5


	DROP TABLE #InvoicesOfInterest	
	DROP TABLE #AccountsToSync

END

GO

