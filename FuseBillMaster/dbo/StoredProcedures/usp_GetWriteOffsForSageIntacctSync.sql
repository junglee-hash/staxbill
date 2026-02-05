
CREATE   PROCEDURE [dbo].[usp_GetWriteOffsForSageIntacctSync]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	CREATE TABLE #CustomersToSync (
		CustomerId BIGINT PRIMARY KEY CLUSTERED
		,SageIntacctSyncTimestamp DATETIME
		,AccountId BIGINT
		,CompanyName NVARCHAR(255))

	--Customers eligible to sync
	INSERT INTO #CustomersToSync (CustomerId,SageIntacctSyncTimestamp,AccountId,CompanyName)
	SELECT 
		c.Id AS CustomerId
		,c.SageIntacctSyncTimestamp
		,a.Id AS AccountId
		,a.CompanyName
	FROM Customer c
	INNER JOIN Account a ON a.Id = c.AccountId
	INNER JOIN AccountSageIntacctConfiguration si ON si.Id = a.Id
		AND si.StatusId = 1
	INNER JOIN AccountFeatureConfiguration afc ON afc.Id = a.Id
		AND afc.SageIntacctEnabled = 1
	WHERE c.SageIntacctId IS NOT NULL

	SELECT 
		cts.AccountId
		,cts.CompanyName
		,w.Id AS WriteOffId
		,w.InvoiceId
		,i.SageIntacctId
		,i.SageIntacctAttemptNumber
	FROM #CustomersToSync cts
	INNER JOIN [Transaction] t ON t.CustomerId = cts.CustomerId 
		AND t.EffectiveTimestamp >= cts.SageIntacctSyncTimestamp
	INNER JOIN WriteOff w ON w.Id = t.Id
		AND w.SageIntacctId IS NULL
		AND w.SageIntacctAttemptNumber < 5
	INNER JOIN Invoice i on i.Id = w.InvoiceId
		AND i.SageIntacctId IS NOT NULL

	DROP TABLE #CustomersToSync

END

GO

