
CREATE   PROCEDURE [dbo].[Staffside_LookupIPByAccount]
	@AccountId VARCHAR(100) 
AS

SET TRANSACTION ISOLATION LEVEL SNAPSHOT

SELECT TOP 20
	tr.IpAddress AS IpAddress
	,COUNT(tr.Id) AS Instances
FROM dbo.AuditTrail tr
WHERE tr.AccountId = @AccountId
AND tr.CreatedTimestamp > DATEADD(MONTH, -3, GETUTCDATE())
GROUP BY tr.IpAddress
ORDER BY Instances desc

GO

