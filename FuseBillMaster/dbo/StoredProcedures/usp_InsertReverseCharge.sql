 
 
CREATE PROC [dbo].[usp_InsertReverseCharge]

	@Id bigint,
	@Reference nvarchar(500),
	@OriginalChargeId bigint,
	@CreditNoteId bigint
AS
SET NOCOUNT ON
	INSERT INTO [ReverseCharge] (
		[Id],
		[Reference],
		[OriginalChargeId],
		[CreditNoteId]
	)
	VALUES (
		@Id,
		@Reference,
		@OriginalChargeId,
		@CreditNoteId
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

