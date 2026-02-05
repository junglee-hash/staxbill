 
 
CREATE PROC [dbo].[usp_InsertCreditNote]

	@InvoiceId bigint,
	@Amount decimal
AS
SET NOCOUNT ON
	INSERT INTO [CreditNote] (
		[InvoiceId],
		[Amount]
	)
	VALUES (
		@InvoiceId,
		@Amount
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

