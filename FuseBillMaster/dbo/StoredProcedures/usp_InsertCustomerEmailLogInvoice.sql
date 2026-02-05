 
 
CREATE PROC [dbo].[usp_InsertCustomerEmailLogInvoice]

	@CustomerEmailLogId bigint,
	@InvoiceId bigint
AS
SET NOCOUNT ON
	INSERT INTO [CustomerEmailLogInvoice] (
		[CustomerEmailLogId],
		[InvoiceId]
	)
	VALUES (
		@CustomerEmailLogId,
		@InvoiceId
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

