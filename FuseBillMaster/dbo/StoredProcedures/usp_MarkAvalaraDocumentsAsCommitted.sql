
CREATE   PROCEDURE [dbo].[usp_MarkAvalaraDocumentsAsCommitted]
	@AccountId BIGINT,
	@CustomerId BIGINT,
	@InvoiceAvalaraId NVARCHAR(255),
	@DocCode NVARCHAR(255)
AS
SET NOCOUNT ON

SELECT 
	Id, 
	AvalaraId 
INTO #candidateInvoices
FROM dbo.Invoice 
	WHERE AccountId = @AccountId
	AND CustomerId = @CustomerId
	AND AvalaraId IS NOT NULL
	
DECLARE @InvoiceId BIGINT

SET @InvoiceId = (
	SELECT Id 
	FROM #candidateInvoices 
	WHERE CAST( AvalaraId AS NVARCHAR(255)) = @InvoiceAvalaraId 
)


DROP TABLE #candidateInvoices

UPDATE [dbo].[AvalaraLog]
SET 
	InvoiceId = @InvoiceId
WHERE AccountId = @AccountId
AND DocCode = @DocCode
AND CustomerId = @CustomerId

IF (@InvoiceAvalaraId = @DocCode)
BEGIN
	--the invoice is either not a unified invoice OR this commit call was for the parent, so update the invoice:

	UPDATE [dbo].[Invoice]
		SET TaxesCommitted = 1
	Where Id = @InvoiceId

END
ELSE
BEGIN
	--this doc code must be for a child, so set the child tax document to committed
	UPDATE [dbo].InvoiceChildTaxDocument
		SET [Committed] = 1
	WHERE InvoiceId = @InvoiceId
	AND DocCode = @DocCode

END
SET NOCOUNT OFF

GO

