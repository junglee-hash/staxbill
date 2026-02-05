
CREATE       PROCEDURE [dbo].[UtilityCheckForAvalaraInvoicesWithUncommttedCalls]

AS
SET NOCOUNT ON

SELECT  
i.Id AS InvoiceId,
CAST( i.AvalaraId AS NVARCHAR(255)) AS AvalaraId
INTO #candidateInvoices
FROM Invoice i
INNER JOIN dbo.Account a on a.Id = i.AccountId
WHERE i.CreatedTimestamp
BETWEEN DATEADD(DAY, -14, GETUTCDATE()) AND DATEADD(DAY, -1, GETUTCDATE())
AND AvalaraId IS NOT NULL
AND a.Live = 1

SELECT 
al.Id 
INTO #problemLogs
FROM dbo.AvalaraLog al
INNER JOIN #candidateInvoices ci ON ci.AvalaraId = al.DocCode
WHERE al.InvoiceId IS NULL

IF((SELECT COUNT(1) FROM #problemLogs) > 0)
BEGIN
exec

			msdb.dbo.sp_send_dbmail 	@profile_name =  'DefaultMailProfile' 

			,@recipients =  'db_alerts@fusebill.com'

			,@subject = 'Failure to commit Avalara Logs'

			,@body = 'Failed to commit Avalara Logs for one or more invoices. Source: dbo.UtilityCheckForAvalaraInvoicesWithUncommttedCalls';

END

DROP TABLE #problemLogs
DROP TABLE #candidateInvoices

SET NOCOUNT OFF

GO

