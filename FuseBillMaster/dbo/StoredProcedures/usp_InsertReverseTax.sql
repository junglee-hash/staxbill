 
 
CREATE PROC [dbo].[usp_InsertReverseTax]

	@Id bigint,
	@OriginalTaxId bigint,
	@CreditNoteId bigint,
	@ReverseChargeId bigint
AS
SET NOCOUNT ON
	INSERT INTO [ReverseTax] (
		[Id],
		[OriginalTaxId],
		[CreditNoteId],
		[ReverseChargeId]
	)
	VALUES (
		@Id,
		@OriginalTaxId,
		@CreditNoteId,
		@ReverseChargeId
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

