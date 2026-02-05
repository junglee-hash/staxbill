CREATE   procedure [dbo].[usp_GetCustomersForNetsuiteManageExportCSV]
	@AccountId bigint
as
select
	N'Fusebill ID' as [FusebillId]
	,N'Customer ID (maximum length of 255 characters)' as [Reference]
	,N'Company name (maximum length of 255 characters)' as [CompanyName]
	,N'First name' as [FirstName]
	,N'Last name' as [LastName]
	,N'Primary email address (comma or semicolon separated, maximum length of 255 characters)' as [PrimaryEmail]
	,N'Current Netsuite ID of the Netsuite Customer of this row' as [NetsuiteId]
	,N'Target Netsuite ID of the Netsuite Customer of this row' as [TargetNetsuiteId]
	,N'Current Netsuite Sync Status of the Netsuite Customer of this row' as [NetsuiteSyncStatus]
	,N'Target Netsuite Sync Status of the Netsuite Customer of this row' as [TargetNetsuiteSyncStatus]
	,N'Target Netsuite Sync Date of the Netsuite Customer of this row' as [TargetNetsuiteSyncDate]
union all

Select 
	Cast (Id as varchar)  as [FusebillId]
	,Reference as [Reference]
	,CompanyName
	,FirstName
	,LastName
	,PrimaryEmail
	,NetsuiteId as [NetsuiteId]
	,null as [TargetSalesforceId]
	, CAST(CASE WHEN NetsuiteSynchStatusId = 1 THEN 'Enabled' WHEN NetsuiteSynchStatusId = 2 THEN 'Disabled' ELSE '' END as varchar) as [NetsuiteSyncStatus]
	,null as [TargetNetsuiteSyncStatus]
	,CONVERT(NVARCHAR, NetsuiteSyncTimestamp) as [TargetNetsuiteSyncDate]
from 
	Customer c 
Where 
	AccountId = @AccountId
	And c.IsDeleted = 0

GO

