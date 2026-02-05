CREATE PROC [dbo].[usp_UpdateWriteOff]

	@Id bigint,
	@InvoiceId bigint,
	@Reference nvarchar(500)
AS
SET NOCOUNT ON
	UPDATE [WriteOff] SET 
		[InvoiceId] = @InvoiceId,
		[Reference] = @Reference
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

