CREATE PROCEDURE [dbo].[Staffside_AccountSalesforceDetails]
AS

BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
	SET NOCOUNT ON;
			
	SELECT 
	a.Id AS [AccountId]
	,a.[CompanyName]
	,a.[Live]
	,a.[FusebillTest]
	,[asc].OrganizationName AS [SalesforceOrganizationName]
	,ss.CreatedTimestamp AS [FirstEntitySyncTimestamp]
	FROM Account a
	INNER JOIN AccountSalesforceConfiguration [asc] ON a.Id = [asc].Id
	OUTER APPLY (
			SELECT TOP 1 CreatedTimestamp
			FROM [SalesforceSyncStatus] ss
			WHERE a.Id = ss.AccountId
			ORDER BY CreatedTimestamp ASC
		) ss;
END

GO

