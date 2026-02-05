CREATE PROC [dbo].[usp_InsertAccountBillingPreference]
	@Id bigint,
	@AutoPostDraftInvoice bit,
	@AccountGracePeriod int,
	@DefaultTermId int,
	@DefaultAutoCollect bit,
	@CustomerAcquisitionCost decimal,
	@ShowZeroDollarCharges bit,
	@DefaultCustomerServiceStartOptionId int,
	@RechargeTypeId int,
	@RechargeThresholdAmount decimal,
	@RechargeTargetAmount decimal,
	@StatusOnThreshold bit,
	@EarnInPreviousPeriod bit,
	@ModifiedTimestamp datetime,
	@AccountAutoCancel int,
	@AccountCancelOption int,
	@PostReadyChargesOnRenew bit,
	@AutoCollectSettingTypeId int,
	@AllowTrackedItemReferenceReuse bit
AS
SET NOCOUNT ON
	INSERT INTO [AccountBillingPreference] (
		[Id],
		[AutoPostDraftInvoice],
		[AccountGracePeriod],
		[DefaultTermId],
		[DefaultAutoCollect],
		[CustomerAcquisitionCost],
		[ShowZeroDollarCharges],
		[DefaultCustomerServiceStartOptionId],
		[RechargeTypeId],
		[RechargeThresholdAmount],
		[RechargeTargetAmount],
		[StatusOnThreshold],
		[EarnInPreviousPeriod],
		[ModifiedTimestamp],
		[AccountAutoCancel],
		[AccountCancelOptionId],
		[PostReadyChargesOnRenew],
		[AutoCollectSettingTypeId],
		[AllowTrackedItemReferenceReuse]
	)
	VALUES (
		@Id,
		@AutoPostDraftInvoice,
		@AccountGracePeriod,
		@DefaultTermId,
		@DefaultAutoCollect,
		@CustomerAcquisitionCost,
		@ShowZeroDollarCharges,
		@DefaultCustomerServiceStartOptionId,
		@RechargeTypeId,
		@RechargeThresholdAmount,
		@RechargeTargetAmount,
		@StatusOnThreshold,
		@EarnInPreviousPeriod,
		@ModifiedTimestamp,
		@AccountAutoCancel,
		@AccountCancelOption,
		@PostReadyChargesOnRenew,
		@AutoCollectSettingTypeId,
		@AllowTrackedItemReferenceReuse
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

