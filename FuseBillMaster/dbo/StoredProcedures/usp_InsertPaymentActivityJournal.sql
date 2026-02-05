CREATE   PROC [dbo].[usp_InsertPaymentActivityJournal]

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
	@ProcessorTypeId INT = NULL,
	@AccountId BIGINT
AS
SET NOCOUNT ON
	INSERT INTO [PaymentActivityJournal] (
		[CustomerId],
		[Amount],
		[AuthorizationCode],
		[PaymentSourceId],
		[PaymentActivityStatusId],
		[PaymentTypeId],
		[CreatedTimestamp],
		[ModifiedTimestamp],
		[EffectiveTimestamp],
		[AuthorizationResponse],
		[PaymentMethodTypeId],
		[CurrencyId],
		[PaymentPlatformCode],
		[GatewayId],
		[GatewayName],
		[PaymentMethodId],
		[SecondaryTransactionNumber],
		[AttemptNumber],
		[ParentCustomerId],
		[ReconciliationId],
		[SettlementStatusId],
		[SettlementStatusModifiedTimestamp],
		[SettlementStatusLastCheckedTimestamp],
		[SettlementStatusNextCheckTimestamp],
		[SettlementStatusMessage],
		[GatewayFee],
		[PrimaryGatewayFailure],
		[SurchargingFee],
		[Trigger],
		[TriggeringUserId],
		[IsDebit],
		[ProcessorTypeId],
		[AccountId]
	)
	VALUES (
		@CustomerId,
		@Amount,
		@AuthorizationCode,
		@PaymentSourceId,
		@PaymentActivityStatusId,
		@PaymentTypeId,
		@CreatedTimestamp,
		@ModifiedTimestamp,
		@EffectiveTimestamp,
		@AuthorizationResponse,
		@PaymentMethodTypeId,
		@CurrencyId,
		@PaymentPlatformCode,
		@GatewayId,
		@GatewayName,
		@PaymentMethodId,
		@SecondaryTransactionNumber,
		@AttemptNumber,
		@ParentCustomerId,
		@ReconciliationId,
		@SettlementStatusId,
		@SettlementStatusModifiedTimestamp,
		@SettlementStatusLastCheckedTimestamp,
		@SettlementStatusNextCheckTimestamp,
		@SettlementStatusMessage,
		@GatewayFee,
		@PrimaryGatewayFailure,
		@SurcharchingFee,
		@Trigger,
		@TriggeringUserId,
		@IsDebit,
		CASE WHEN @ProcessorTypeId = 0 THEN NULL ELSE @ProcessorTypeId END,
		@AccountId
	)

	DECLARE @Id bigint
	SELECT @Id = @@IDENTITY

	-- If the settlement status is not unknown upsert on the
	-- AccountGatewayReconciliation incrementing the CountOfPending
	IF @SettlementStatusId != 1
	BEGIN
		MERGE AccountGatewayReconciliation WITH (HOLDLOCK) as acr
		USING (SELECT c.AccountId FROM Customer c WHERE c.Id = @CustomerId) AS customer
					ON acr.Id = customer.AccountId
		WHEN MATCHED THEN
			UPDATE SET 
				acr.CountOfPending = CASE WHEN @SettlementStatusId = 2 THEN acr.CountOfPending + 1 ELSE acr.CountOfPending END
				, acr.CountOfSuccessful = CASE WHEN @SettlementStatusId = 3 THEN acr.CountOfSuccessful + 1 ELSE acr.CountOfSuccessful END
				, acr.CountOfFailed = CASE WHEN @SettlementStatusId = 4 THEN acr.CountOfFailed + 1 ELSE acr.CountOfFailed END
				, acr.NextCheckTimestamp = CASE WHEN acr.NextCheckTimestamp < @SettlementStatusNextCheckTimestamp 
						THEN acr.NextCheckTimestamp 
						ELSE @SettlementStatusNextCheckTimestamp END -- Set Next check timestamp based on if new value is less than current value
				, acr.ModifiedTimestamp = GETUTCDATE()
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

		UPDATE Account SET ModifiedTimestamp = GETUTCDATE() WHERE Id = @AccountId
	END

	SELECT @Id as Id
SET NOCOUNT OFF

GO

