CREATE   PROCEDURE [dbo].[usp_GetCustomersForSageIntacctSync]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	CREATE TABLE #AccountsToSync (
		AccountId BIGINT PRIMARY KEY CLUSTERED
		,CompanyName NVARCHAR(255))

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

	SELECT 
		ats.AccountId
		,ats.CompanyName
		,c.Id AS CustomerId
	FROM #AccountsToSync ats
	INNER JOIN Customer c ON c.AccountId = ats.AccountId
	WHERE c.SageIntacctId IS NOT NULL
		AND c.ModifiedTimestamp > c.SageIntacctSyncTimestamp

	DROP TABLE #AccountsToSync

END

GO

