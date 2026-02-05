CREATE procedure [dbo].[usp_GetCustomersForActivationExportCSV]
	@AccountId bigint
as
select
	N'Fusebill Id' as [FusebillId]
	,N'Customer ID (maximum length of 255 characters)' as [Reference]
	,N'Company name (maximum length of 255 characters)' as [CompanyName]
	,N'Primary email address (comma or semicolon separated, maximum length of 255 characters)' as [PrimaryEmail]
union all

Select 
	Cast (Id as varchar)  as [FusebillId]
	,Reference as [Reference]
	,CompanyName
	,PrimaryEmail
from 
	Customer c 
Where 
	AccountId = @AccountId
	AND c.StatusId = 1
	And c.IsDeleted = 0

GO

