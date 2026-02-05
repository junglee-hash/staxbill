 
 
CREATE PROC [dbo].[usp_InsertCharge]

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
	INSERT INTO [Charge] (
		[Id],
		[InvoiceId],
		[DraftChargeId],
		[UnitPrice],
		[Quantity],
		[EarningStartDate],
		[EarningEndDate],
		[Name],
		[ProratedUnitPrice],
		[RangeQuantity],
		[RemainingReverseAmount],
		[ChargeGroupId],
		[EarningTimingTypeId],
		[EarningTimingIntervalId],
		[GLCodeId]
	)
	VALUES (
		@Id,
		@InvoiceId,
		@DraftChargeId,
		@UnitPrice,
		@Quantity,
		@EarningStartDate,
		@EarningEndDate,
		@Name,
		@ProratedUnitPrice,
		@RangeQuantity,
		@RemainingReverseAmount,
		@ChargeGroupId,
		@EarningTimingTypeId,
		@EarningTimingIntervalId,
		@GLCodeId
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

