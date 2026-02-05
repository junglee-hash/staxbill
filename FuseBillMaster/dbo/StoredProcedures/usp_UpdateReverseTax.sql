CREATE PROC [dbo].[usp_UpdateReverseTax]

	@Id bigint,
	@OriginalTaxId bigint,
	@CreditNoteId bigint,
	@ReverseChargeId bigint
AS
SET NOCOUNT ON
	UPDATE [ReverseTax] SET 
		[OriginalTaxId] = @OriginalTaxId,
		[CreditNoteId] = @CreditNoteId,
		[ReverseChargeId] = @ReverseChargeId
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

