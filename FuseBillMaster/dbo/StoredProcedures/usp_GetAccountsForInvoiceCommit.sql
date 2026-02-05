
CREATE     PROCEDURE [dbo].[usp_GetAccountsForInvoiceCommit]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

SELECT a.Live, a.Id AS AccountId
INTO #candidateAccounts
FROM Account a
INNER JOIN AvalaraConfiguration ac ON ac.Id = a.Id
INNER JOIN AccountFeatureConfiguration afc on afc.Id = a.Id
WHERE ac.[Enabled] = 1
AND ac.CommitTaxes = 1
AND a.IncludeInAutomatedProcesses = 1
AND afc.TaxOptionId in (3,4) --Advanced Taxation, Avalara Direct Taxation

SELECT ca.*
INTO #candidateInvoices
FROM dbo.Invoice i
INNER JOIN #candidateAccounts ca ON i.AccountId = ca.AccountId
WHERE i.TaxesCommitted = 0
AND i.AvalaraId IS NOT NULL

SELECT ca.* 
INTO #candidateChildTaxDocuments
FROM InvoiceChildTaxDocument ictd
INNER JOIN dbo.Invoice i ON i.Id = ictd.InvoiceId
INNER JOIN #candidateAccounts ca ON ca.AccountId = i.AccountId
WHERE ictd.[Committed] = 0

SELECT DISTINCT q.AccountId, q.Live
FROM (
	SELECT DISTINCT AccountId, Live
	FROM #candidateInvoices
	UNION
	SELECT DISTINCT AccountId, Live
	FROM #candidateChildTaxDocuments
) AS q
ORDER BY q.Live DESC


DROP TABLE #candidateChildTaxDocuments
DROP TABLE #candidateInvoices
DROP TABLE #candidateAccounts

END

GO

