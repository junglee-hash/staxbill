
CREATE   PROCEDURE [dbo].[Staffside_LookupAccountByIP]
	@IPAddress VARCHAR(100) 
AS

SET TRANSACTION ISOLATION LEVEL SNAPSHOT

SELECT TOP 20
	a.Id AS AccountId
	,a.CompanyName AS AccountName
	,COUNT(tr.Id) AS Instances
FROM Account a
INNER JOIN dbo.AuditTrail tr ON tr.AccountId = a.Id
WHERE tr.IpAddress = @IPAddress
AND tr.CreatedTimestamp > DATEADD(MONTH, -3, GETUTCDATE())
GROUP BY a.Id, a.CompanyName
ORDER BY Instances desc

GO

