
CREATE     PROC [dbo].[usp_UpdateAvalaraLog]

	@Id bigint,	
	@DraftInvoiceId bigint,
	@InvoiceId bigint,
	@DocCode nvarchar(255)
AS
SET NOCOUNT ON
	--we drop many of these values in memory to save on memory, 
	--they'll be there from the initial insert and shoudln't change
	--thus we're only going to let you change a saved logs draft invoice id, invoice id, or code
	UPDATE [AvalaraLog] SET 
		[DraftInvoiceId] = @DraftInvoiceId,
		[InvoiceId] = @InvoiceId,
		[DocCode] = @DocCode
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

