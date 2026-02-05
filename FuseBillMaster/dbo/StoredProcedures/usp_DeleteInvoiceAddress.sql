CREATE PROC [dbo].[usp_DeleteInvoiceAddress]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [InvoiceAddress]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

