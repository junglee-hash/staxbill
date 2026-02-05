 
 
CREATE PROC [dbo].[usp_InsertReverseDiscount]

	@Id bigint,
	@Reference varchar(500),
	@OriginalDiscountId bigint,
	@CreditNoteId bigint,
	@ReverseChargeId bigint
AS
SET NOCOUNT ON
	INSERT INTO [ReverseDiscount] (
		[Id],
		[Reference],
		[OriginalDiscountId],
		[CreditNoteId],
		[ReverseChargeId]
	)
	VALUES (
		@Id,
		@Reference,
		@OriginalDiscountId,
		@CreditNoteId,
		@ReverseChargeId
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

