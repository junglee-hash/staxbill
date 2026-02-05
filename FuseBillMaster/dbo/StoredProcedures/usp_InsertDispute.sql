 
 
CREATE PROC [dbo].[usp_InsertDispute]

	@InvoiceId bigint
AS
SET NOCOUNT ON
	INSERT INTO [Dispute] (
		[InvoiceId]
	)
	VALUES (
		@InvoiceId
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

