
CREATE   PROCEDURE [dbo].[usp_GetInvoicesForSageIntacctSync]
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
	INNER JOIN AccountSageIntacctConfiguration si ON si.Id = a.Id
		AND si.StatusId = 1
	INNER JOIN AccountFeatureConfiguration afc ON afc.Id = a.Id
		AND afc.SageIntacctEnabled = 1

		INSERT INTO #InvoicesOfInterest (InvoiceId,CompanyName,AccountId)
	SELECT 
		i.Id AS InvoiceId
		,ats.CompanyName
		,ats.AccountId
	FROM #AccountsToSync ats
	INNER JOIN Invoice i ON i.AccountId = ats.AccountId
	INNER JOIN Customer c ON c.Id = i.CustomerId
	WHERE c.SageIntacctId IS NOT NULL
		AND i.EffectiveTimestamp >= c.SageIntacctSyncTimestamp

	SELECT
		ii.AccountId
		,ii.CompanyName
		,ii.InvoiceId
	FROM #InvoicesOfInterest ii
	INNER JOIN Invoice i ON i.Id = ii.InvoiceId
	WHERE i.SageIntacctId IS NULL
		AND i.SageIntacctAttemptNumber < 5


	DROP TABLE #InvoicesOfInterest	
	DROP TABLE #AccountsToSync

END

GO

