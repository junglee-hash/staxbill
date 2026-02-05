 
 
CREATE PROC [dbo].[usp_InsertEarningDiscount]

	@Id bigint,
	@DiscountId bigint,
	@Reference nvarchar(500)
AS
SET NOCOUNT ON
	INSERT INTO [EarningDiscount] (
		[Id],
		[DiscountId],
		[Reference]
	)
	VALUES (
		@Id,
		@DiscountId,
		@Reference
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

