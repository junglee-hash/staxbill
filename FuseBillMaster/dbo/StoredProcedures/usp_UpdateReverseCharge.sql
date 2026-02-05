CREATE PROC [dbo].[usp_UpdateReverseCharge]

	@Id bigint,
	@Reference nvarchar(500),
	@OriginalChargeId bigint,
	@CreditNoteId bigint
AS
SET NOCOUNT ON
	UPDATE [ReverseCharge] SET 
		[Reference] = @Reference,
		[OriginalChargeId] = @OriginalChargeId,
		[CreditNoteId] = @CreditNoteId
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

