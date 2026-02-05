 
 
CREATE PROC [dbo].[usp_InsertWriteOff]

	@Id bigint,
	@InvoiceId bigint,
	@Reference nvarchar(500)
AS
SET NOCOUNT ON
	INSERT INTO [WriteOff] (
		[Id],
		[InvoiceId],
		[Reference]
	)
	VALUES (
		@Id,
		@InvoiceId,
		@Reference
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

