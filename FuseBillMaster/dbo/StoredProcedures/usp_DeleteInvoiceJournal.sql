CREATE PROC [dbo].[usp_DeleteInvoiceJournal]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [InvoiceJournal]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

