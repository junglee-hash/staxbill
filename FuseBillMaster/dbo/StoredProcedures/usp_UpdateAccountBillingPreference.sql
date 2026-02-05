CREATE PROC [dbo].[usp_UpdateAccountBillingPreference]

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
	UPDATE [AccountBillingPreference] SET 
		[AutoPostDraftInvoice] = @AutoPostDraftInvoice,
		[AccountGracePeriod] = @AccountGracePeriod,
		[DefaultTermId] = @DefaultTermId,
		[DefaultAutoCollect] = @DefaultAutoCollect,
		[CustomerAcquisitionCost] = @CustomerAcquisitionCost,
		[ShowZeroDollarCharges] = @ShowZeroDollarCharges,
		[DefaultCustomerServiceStartOptionId] = @DefaultCustomerServiceStartOptionId,
		[RechargeTypeId] = @RechargeTypeId,
		[RechargeThresholdAmount] = @RechargeThresholdAmount,
		[RechargeTargetAmount] = @RechargeTargetAmount,
		[StatusOnThreshold] = @StatusOnThreshold,
		[EarnInPreviousPeriod] = @EarnInPreviousPeriod,
		[ModifiedTimestamp] = @ModifiedTimestamp,
		[AccountAutoCancel] = @AccountAutoCancel,
		[AccountCancelOptionId] = @AccountCancelOption,
		[PostReadyChargesOnRenew] = @PostReadyChargesOnRenew,
		[AutoCollectSettingTypeId] = @AutoCollectSettingTypeId,
		[AllowTrackedItemReferenceReuse] = @AllowTrackedItemReferenceReuse
	WHERE [Id] = @Id;
SET NOCOUNT OFF

GO

