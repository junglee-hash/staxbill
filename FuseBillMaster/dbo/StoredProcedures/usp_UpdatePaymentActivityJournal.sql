CREATE     PROC [dbo].[usp_UpdatePaymentActivityJournal]

	@Id bigint,
	@CustomerId bigint,
	@Amount money,
	@AuthorizationCode varchar(255),
	@PaymentSourceId int,
	@PaymentActivityStatusId int,
	@PaymentTypeId int,
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime,
	@EffectiveTimestamp datetime,
	@AuthorizationResponse varchar(500),
	@PaymentMethodTypeId int,
	@CurrencyId bigint,
	@PaymentPlatformCode varchar(255),
	@GatewayId bigint,
	@GatewayName nvarchar(Max),
	@PaymentMethodId bigint,
	@SecondaryTransactionNumber varchar(255),
	@AttemptNumber tinyint,
	@ParentCustomerId bigint,
	@ReconciliationId uniqueidentifier,
	@DisputeStatusId tinyint,
	@ExternalDisputeId varchar(255),
	@SettlementStatusId tinyint,
	@SettlementStatusModifiedTimestamp datetime,
	@SettlementStatusLastCheckedTimestamp datetime,
	@SettlementStatusNextCheckTimestamp datetime,
	@SettlementStatusMessage varchar(500),
	@GatewayFee decimal(18,6),
	@PrimaryGatewayFailure varchar(500),
	@SurcharchingFee money,
	@Trigger nvarchar(60) = null,
	@TriggeringUserId BIGINT = null,
	@IsDebit bit,
	@ProcessorTypeId INT = NULL
AS
SET NOCOUNT ON

	DECLARE @ExistingSettlementStatusId tinyint
	SELECT @ExistingSettlementStatusId = [SettlementStatusId] FROM [PaymentActivityJournal] WHERE [Id] = @Id

	UPDATE [PaymentActivityJournal] SET 
		[CustomerId] = @CustomerId,
		[Amount] = @Amount,
		[AuthorizationCode] = @AuthorizationCode,
		[PaymentSourceId] = @PaymentSourceId,
		[PaymentActivityStatusId] = @PaymentActivityStatusId,
		[PaymentTypeId] = @PaymentTypeId,
		[CreatedTimestamp] = @CreatedTimestamp,
		[ModifiedTimestamp] = @ModifiedTimestamp,
		[EffectiveTimestamp] = @EffectiveTimestamp,
		[AuthorizationResponse] = @AuthorizationResponse,
		[PaymentMethodTypeId] = @PaymentMethodTypeId,
		[CurrencyId] = @CurrencyId,
		[PaymentPlatformCode] = @PaymentPlatformCode,
		[GatewayId] = @GatewayId,
		[GatewayName] = @GatewayName,
		[PaymentMethodId] = @PaymentMethodId,
		[SecondaryTransactionNumber] = @SecondaryTransactionNumber,
		[AttemptNumber] = @AttemptNumber,
		[ParentCustomerId] = @ParentCustomerId,
		[ReconciliationId] = @ReconciliationId,
		[DisputeStatusId] = @DisputeStatusId,
		[ExternalDisputeId] = @ExternalDisputeId,
		[SettlementStatusId] = @SettlementStatusId,
		[SettlementStatusModifiedTimestamp] = @SettlementStatusModifiedTimestamp,
		[SettlementStatusLastCheckedTimestamp] = @SettlementStatusLastCheckedTimestamp,
		[SettlementStatusNextCheckTimestamp] = @SettlementStatusNextCheckTimestamp,
		[SettlementStatusMessage] = @SettlementStatusMessage,
		[GatewayFee] = @GatewayFee,
		[PrimaryGatewayFailure] = @PrimaryGatewayFailure,
		[SurchargingFee] = @SurcharchingFee,
		[Trigger] = @Trigger,
		[TriggeringUserId] = @TriggeringUserId,
		[IsDebit] = @IsDebit,
		[ProcessorTypeId] = CASE WHEN @ProcessorTypeId = 0 THEN NULL ELSE @ProcessorTypeId END
	WHERE [Id] = @Id

	-- If the settlement status is not unknown, update the gateway reconciliation appropriately
	IF @SettlementStatusId != 1
	BEGIN
		DECLARE @AccountId bigint
		SELECT @AccountId = AccountId FROM Customer WHERE Id = @CustomerId

		DECLARE @NextCheckTimestamp datetime
		SELECT @NextCheckTimestamp = MIN([SettlementStatusNextCheckTimestamp]) 
		FROM PaymentActivityJournal paj
		INNER JOIN Customer c ON c.Id = paj.CustomerId AND c.AccountId = @AccountId
		WHERE paj.[SettlementStatusId] = 2

		MERGE AccountGatewayReconciliation WITH (HOLDLOCK) as acr
		USING (SELECT @AccountId as AccountId) AS customer
					ON acr.Id = customer.AccountId
		WHEN MATCHED THEN
			UPDATE SET 
				acr.NextCheckTimestamp = @NextCheckTimestamp
				, acr.ModifiedTimestamp = GETUTCDATE()
				, acr.CountOfPending = CASE WHEN @ExistingSettlementStatusId = 2 AND @SettlementStatusId != 2 THEN acr.CountOfPending - 1 ELSE acr.CountOfPending END
				, acr.CountOfSuccessful = CASE WHEN @ExistingSettlementStatusId = 2 AND @SettlementStatusId = 3 THEN acr.CountOfSuccessful + 1 ELSE acr.CountOfSuccessful END
				, acr.CountOfFailed = CASE WHEN @ExistingSettlementStatusId = 2 AND @SettlementStatusId = 4 THEN acr.CountOfFailed + 1 ELSE acr.CountOfFailed END
		WHEN NOT MATCHED THEN
			INSERT (
				Id
				, CountOfPending
				, CountOfSuccessful
				, CountOfFailed
				, LastCheckedTimestamp
				, NextCheckTimestamp
				, CreatedTimestamp
				, ModifiedTimestamp
			) VALUES (
				customer.AccountId
				, CASE WHEN @SettlementStatusId = 2 THEN 1 ELSE 0 END
				, CASE WHEN @SettlementStatusId = 3 THEN 1 ELSE 0 END
				, CASE WHEN @SettlementStatusId = 4 THEN 1 ELSE 0 END
				, null
				, @SettlementStatusNextCheckTimestamp
				, GETUTCDATE()
				, GETUTCDATE()
			);
	END

SET NOCOUNT OFF

GO

