
CREATE   PROCEDURE [dbo].[usp_GetReverseChargesForSageIntacctSync]
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
		,rc.Id as ReverseChargeId
		,ch.InvoiceId
		,i.SageIntacctId
		,i.SageIntacctAttemptNumber
	FROM #CustomersToSync cts
	INNER JOIN [Transaction] t ON t.CustomerId = cts.CustomerId 
		AND t.EffectiveTimestamp >= cts.SageIntacctSyncTimestamp
	INNER JOIN ReverseCharge rc ON rc.Id = t.Id
		AND rc.SageIntacctId IS NULL
		AND rc.SageIntacctAttemptNumber < 5
	INNER JOIN Charge ch ON ch.Id = rc.OriginalChargeId
	INNER JOIN Invoice i on i.Id = ch.InvoiceId
		AND i.SageIntacctId IS NOT NULL

	DROP TABLE #CustomersToSync

END

GO

