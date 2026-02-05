CREATE PROC [dbo].[usp_UpdateEarningDiscount]

	@Id bigint,
	@DiscountId bigint,
	@Reference nvarchar(500)
AS
SET NOCOUNT ON
	UPDATE [EarningDiscount] SET 
		[DiscountId] = @DiscountId,
		[Reference] = @Reference
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

