CREATE PROC [dbo].[usp_DeleteInvoiceCustomer]
	@InvoiceId bigint
AS
SET NOCOUNT ON

DELETE FROM [InvoiceCustomer]
WHERE [InvoiceId] = @InvoiceId

SET NOCOUNT OFF

GO

