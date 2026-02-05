CREATE PROC [dbo].[usp_UpdateReverseDiscount]

	@Id bigint,
	@Reference varchar(500),
	@OriginalDiscountId bigint,
	@CreditNoteId bigint,
	@ReverseChargeId bigint
AS
SET NOCOUNT ON
	UPDATE [ReverseDiscount] SET 
		[Reference] = @Reference,
		[OriginalDiscountId] = @OriginalDiscountId,
		[CreditNoteId] = @CreditNoteId,
		[ReverseChargeId] = @ReverseChargeId
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

