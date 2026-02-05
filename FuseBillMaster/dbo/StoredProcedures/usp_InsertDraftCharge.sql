 
 
CREATE PROC [dbo].[usp_InsertDraftCharge]

	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime,
	@Quantity decimal,
	@UnitPrice money,
	@Amount money,
	@DraftInvoiceId bigint,
	@Name nvarchar(2000),
	@Description nvarchar(2000),
	@TransactionTypeId int,
	@CurrencyId bigint,
	@EffectiveTimestamp datetime,
	@ProratedUnitPrice decimal,
	@RangeQuantity decimal,
	@TaxableAmount decimal,
	@StatusId int,
	@SortOrder tinyint,
	@CustomerId bigint,
	@EarningTimingTypeId int,
	@EarningTimingIntervalId int
AS
SET NOCOUNT ON
	INSERT INTO [DraftCharge] (
		[CreatedTimestamp],
		[ModifiedTimestamp],
		[Quantity],
		[UnitPrice],
		[Amount],
		[DraftInvoiceId],
		[Name],
		[Description],
		[TransactionTypeId],
		[CurrencyId],
		[EffectiveTimestamp],
		[ProratedUnitPrice],
		[RangeQuantity],
		[TaxableAmount],
		[StatusId],
		[SortOrder],
		[CustomerId],
		[EarningTimingTypeId],
		[EarningTimingIntervalId]
	)
	VALUES (
		@CreatedTimestamp,
		@ModifiedTimestamp,
		@Quantity,
		@UnitPrice,
		@Amount,
		@DraftInvoiceId,
		@Name,
		@Description,
		@TransactionTypeId,
		@CurrencyId,
		@EffectiveTimestamp,
		@ProratedUnitPrice,
		@RangeQuantity,
		@TaxableAmount,
		@StatusId,
		@SortOrder,
		@CustomerId,
		@EarningTimingTypeId,
		@EarningTimingIntervalId
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

