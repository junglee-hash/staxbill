CREATE   procedure [dbo].[usp_GetCustomersForAvalaraManageExportCSV]
	@AccountId bigint
as
select
	N'Fusebill ID' as [FusebillId]
	,N'Customer ID (maximum length of 255 characters)' as [Reference]
	,N'Company name (maximum length of 255 characters)' as [CompanyName]
	,N'First name' as [FirstName]
	,N'Last name' as [LastName]
	,N'Primary email address (comma or semicolon separated, maximum length of 255 characters)' as [PrimaryEmail]
	,N'Current Avalara ID of the customer of this row' as [AvalaraId]
	,N'Target Avalara ID of the customer of this row' as [TargetAvalaraId]
union all

Select 
	Cast (Id as varchar)  as [FusebillId]
	,Reference as [Reference]
	,CompanyName
	,FirstName
	,LastName
	,PrimaryEmail
	,AvalaraId as [AvalaraId]
	,null as [TargetAvalaraId]
from 
	Customer c 
Where 
	AccountId = @AccountId
	And c.IsDeleted = 0

GO

