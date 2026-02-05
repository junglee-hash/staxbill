CREATE PROC [dbo].[usp_UpdateCreditNote]

	@Id bigint,
	@InvoiceId bigint,
	@Amount decimal
AS
SET NOCOUNT ON
	UPDATE [CreditNote] SET 
		[InvoiceId] = @InvoiceId,
		[Amount] = @Amount
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

