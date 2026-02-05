CREATE PROC [dbo].[usp_UpdateDispute]

	@Id bigint,
	@InvoiceId bigint
AS
SET NOCOUNT ON
	UPDATE [Dispute] SET 
		[InvoiceId] = @InvoiceId
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

