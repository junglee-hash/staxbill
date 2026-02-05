
CREATE procedure [dbo].[usp_GetCustomReportsWithNameAndId]

AS
set transaction isolation level snapshot
set nocount on

SET NOCOUNT OFF

SELECT 
	a.Id as Id
	,a.Name as Name
FROM Report a
ORDER BY a.Name

SET NOCOUNT OFF

GO

