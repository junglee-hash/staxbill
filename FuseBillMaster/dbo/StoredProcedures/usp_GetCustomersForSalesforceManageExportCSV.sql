CREATE   procedure [dbo].[usp_GetCustomersForSalesforceManageExportCSV]
	@AccountId bigint
as
select
	N'Fusebill ID' as [FusebillId]
	,N'Customer ID (maximum length of 255 characters)' as [Reference]
	,N'Company name (maximum length of 255 characters)' as [CompanyName]
	,N'Primary email address (comma or semicolon separated, maximum length of 255 characters)' as [PrimaryEmail]
	,N'Current Salesforce ID of the Salesforce account currently customer of this row' as [SalesforceId]
	,N'Target Salesforce Account ID ("clear" to unlink)' as [TargetSalesforceId]
	,N'Salesforce Status (Enabled / Disabled)' as [SalesforceSyncStatus]
	,N'Target Salesforce Status (Enabled / Disabled)' as [TargetSalesforceSyncStatus]
union all

Select 
	Cast (Id as varchar)  as [FusebillId]
	,Reference as [Reference]
	,CompanyName
	,PrimaryEmail
	,SalesforceId as [SalesforceId]
	,null as [TargetSalesforceId]
	, CAST(CASE WHEN SalesforceSynchStatusId = 1 THEN 'Enabled' WHEN SalesforceSynchStatusId = 2 THEN 'Disabled' ELSE '' END as varchar) as [SalesforceSyncStatus]
	,null as [TargetSalesforceSynchStatus]
from 
	Customer c 
Where 
	AccountId = @AccountId
	And c.IsDeleted = 0

GO

