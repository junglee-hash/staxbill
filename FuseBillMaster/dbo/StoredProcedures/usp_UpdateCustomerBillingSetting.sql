
CREATE PROC [dbo].[usp_UpdateCustomerBillingSetting]

	@Id bigint,
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime,
	@InvoiceDay int,
	@TermId int,
	@IntervalId int,
	@AutoCollect bit,
	@AutoPostDraftInvoice bit,
	@CustomerGracePeriod int,
	@GracePeriodExtension int,
	@StandingPo varchar(255),
	@AcquisitionCost decimal,
	@ShowZeroDollarCharges bit,
	@TaxExempt bit,
	@TaxExemptCode nvarchar(255),
	@CustomerServiceStartOptionId int,
	@RechargeTypeId int,
	@RechargeThresholdAmount decimal,
	@RechargeTargetAmount decimal,
	@StatusOnThreshold bit,
	@AvalaraUsageType varchar(4),
	@VATIdentificationNumber nvarchar(25),
	@UseCustomerBillingAddress bit
AS
SET NOCOUNT ON
	UPDATE [CustomerBillingSetting] SET 
		[CreatedTimestamp] = @CreatedTimestamp,
		[ModifiedTimestamp] = @ModifiedTimestamp,
		[InvoiceDay] = @InvoiceDay,
		[TermId] = @TermId,
		[IntervalId] = @IntervalId,
		[AutoCollect] = @AutoCollect,
		[AutoPostDraftInvoice] = @AutoPostDraftInvoice,
		[CustomerGracePeriod] = @CustomerGracePeriod,
		[GracePeriodExtension] = @GracePeriodExtension,
		[StandingPo] = @StandingPo,
		[AcquisitionCost] = @AcquisitionCost,
		[ShowZeroDollarCharges] = @ShowZeroDollarCharges,
		[TaxExempt] = @TaxExempt,
		[TaxExemptCode] = @TaxExemptCode,
		[CustomerServiceStartOptionId] = @CustomerServiceStartOptionId,
		[RechargeTypeId] = @RechargeTypeId,
		[RechargeThresholdAmount] = @RechargeThresholdAmount,
		[RechargeTargetAmount] = @RechargeTargetAmount,
		[StatusOnThreshold] = @StatusOnThreshold,
		[AvalaraUsageType] = @AvalaraUsageType,
		[VATIdentificationNumber] = @VATIdentificationNumber,
		[UseCustomerBillingAddress] = @UseCustomerBillingAddress
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

