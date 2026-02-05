 
 
CREATE PROC [dbo].[usp_InsertDiscount]

	@Id bigint,
	@ChargeId bigint,
	@ConfiguredDiscountAmount decimal,
	@DiscountTypeId int,
	@RemainingReversalAmount decimal,
	@UnearnedAmount decimal,
	@Quantity decimal
AS
SET NOCOUNT ON
	INSERT INTO [Discount] (
		[Id],
		[ChargeId],
		[ConfiguredDiscountAmount],
		[DiscountTypeId],
		[RemainingReversalAmount],
		[UnearnedAmount],
		[Quantity]
	)
	VALUES (
		@Id,
		@ChargeId,
		@ConfiguredDiscountAmount,
		@DiscountTypeId,
		@RemainingReversalAmount,
		@UnearnedAmount,
		@Quantity
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

