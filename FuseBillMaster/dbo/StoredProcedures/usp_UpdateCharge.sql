CREATE PROC [dbo].[usp_UpdateCharge]

	@Id bigint,
	@InvoiceId bigint,
	@DraftChargeId bigint,
	@UnitPrice money,
	@Quantity decimal,
	@EarningStartDate datetime,
	@EarningEndDate datetime,
	@Name nvarchar(2000),
	@ProratedUnitPrice decimal,
	@RangeQuantity decimal,
	@RemainingReverseAmount decimal,
	@ChargeGroupId bigint,
	@EarningTimingTypeId int,
	@EarningTimingIntervalId int,
	@GLCodeId bigint
AS
SET NOCOUNT ON
	UPDATE [Charge] SET 
		[InvoiceId] = @InvoiceId,
		[DraftChargeId] = @DraftChargeId,
		[UnitPrice] = @UnitPrice,
		[Quantity] = @Quantity,
		[EarningStartDate] = @EarningStartDate,
		[EarningEndDate] = @EarningEndDate,
		[Name] = @Name,
		[ProratedUnitPrice] = @ProratedUnitPrice,
		[RangeQuantity] = @RangeQuantity,
		[RemainingReverseAmount] = @RemainingReverseAmount,
		[ChargeGroupId] = @ChargeGroupId,
		[EarningTimingTypeId] = @EarningTimingTypeId,
		[EarningTimingIntervalId] = @EarningTimingIntervalId,
		[GLCodeId] = @GLCodeId
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

