
CREATE   PROCEDURE [dbo].[usp_GetInvoicesForCommit]
	@AccountId BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

SELECT i.Id as InvoiceId
INTO #invoices
FROM dbo.Invoice i WHERE AccountId = @AccountId
AND i.TaxesCommitted = 0
AND i.AvalaraId IS NOT NULL

SELECT ictd.InvoiceId 
INTO #childTaxDocuments
FROM InvoiceChildTaxDocument ictd
INNER JOIN dbo.Invoice i ON i.Id = ictd.InvoiceId
WHERE ictd.[Committed] = 0
AND AccountId = @AccountId

SELECT DISTINCT q.InvoiceId
FROM (
	SELECT InvoiceId
	FROM #invoices
	UNION
	SELECT InvoiceId
	FROM #childTaxDocuments
) AS q

DROP TABLE #childTaxDocuments
DROP TABLE #invoices

END

GO

