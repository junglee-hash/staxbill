 
 
CREATE PROC [dbo].[usp_InsertDraftDiscount]

	@ConfiguredDiscountAmount decimal,
	@Amount decimal,
	@DraftChargeId bigint,
	@DiscountTypeId int,
	@CreatedTimestamp datetime,
	@EffectiveTimestamp datetime,
	@TransactionTypeId int,
	@Description nvarchar(2000),
	@CurrencyId bigint,
	@Quantity decimal
AS
SET NOCOUNT ON
	INSERT INTO [DraftDiscount] (
		[ConfiguredDiscountAmount],
		[Amount],
		[DraftChargeId],
		[DiscountTypeId],
		[CreatedTimestamp],
		[EffectiveTimestamp],
		[TransactionTypeId],
		[Description],
		[CurrencyId],
		[Quantity]
	)
	VALUES (
		@ConfiguredDiscountAmount,
		@Amount,
		@DraftChargeId,
		@DiscountTypeId,
		@CreatedTimestamp,
		@EffectiveTimestamp,
		@TransactionTypeId,
		@Description,
		@CurrencyId,
		@Quantity
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

