
CREATE procedure [dbo].[usp_GetAccountsWithNameAndId]

AS
set transaction isolation level snapshot
set nocount on

SET NOCOUNT OFF

SELECT 
	a.Id as AccountId
	,a.CompanyName as CompanyName
FROM Account a
ORDER BY a.CompanyName

SET NOCOUNT OFF

GO

