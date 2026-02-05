

CREATE      PROCEDURE [dbo].[usp_AssociateAvalaraLogsToInvoice]
	@AccountId BIGINT,
	@CustomerId BIGINT,
	@DocCode NVARCHAR(255)
WITH RECOMPILE
AS
BEGIN
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
		WHERE CAST( AvalaraId AS NVARCHAR(255)) = @DocCode 
		)

	DROP TABLE #candidateInvoices

	IF @InvoiceId IS NULL
	BEGIN
		RAISERROR (15600,-1,-1, 'No invoice relates to the document code');
		RETURN 55555
	END


	SELECT DocCode 
	INTO #documentCodes
	FROM (
		SELECT
		AvalaraId AS DocCode
		FROM Invoice 
		WHERE Id = @InvoiceId

		UNION

		Select 
		DocCode
		FROM InvoiceChildTaxDocument
		WHERE InvoiceId = @InvoiceId
		) 
	AS q

	UPDATE [dbo].[AvalaraLog]
	SET 
		InvoiceId = @InvoiceId
	FROM [dbo].[AvalaraLog]
	INNER JOIN #documentCodes dc on dc.DocCode = [dbo].[AvalaraLog].DocCode
	WHERE AccountId = @AccountId
	AND CustomerId = @CustomerId

	DROP TABLE #documentCodes

	SET NOCOUNT OFF
END

GO

