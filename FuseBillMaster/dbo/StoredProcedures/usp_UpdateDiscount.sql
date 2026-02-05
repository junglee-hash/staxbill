CREATE PROC [dbo].[usp_UpdateDiscount]

	@Id bigint,
	@ChargeId bigint,
	@ConfiguredDiscountAmount decimal,
	@DiscountTypeId int,
	@RemainingReversalAmount decimal,
	@UnearnedAmount decimal,
	@Quantity decimal
AS
SET NOCOUNT ON
	UPDATE [Discount] SET 
		[ChargeId] = @ChargeId,
		[ConfiguredDiscountAmount] = @ConfiguredDiscountAmount,
		[DiscountTypeId] = @DiscountTypeId,
		[RemainingReversalAmount] = @RemainingReversalAmount,
		[UnearnedAmount] = @UnearnedAmount,
		[Quantity] = @Quantity
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

