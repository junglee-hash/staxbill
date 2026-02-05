CREATE PROC [dbo].[usp_UpdateCustomerEmailLogInvoice]

	@Id bigint,
	@CustomerEmailLogId bigint,
	@InvoiceId bigint
AS
SET NOCOUNT ON
	UPDATE [CustomerEmailLogInvoice] SET 
		[CustomerEmailLogId] = @CustomerEmailLogId,
		[InvoiceId] = @InvoiceId
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

