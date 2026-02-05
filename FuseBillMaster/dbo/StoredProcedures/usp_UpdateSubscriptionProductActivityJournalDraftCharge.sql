CREATE PROC [dbo].[usp_UpdateSubscriptionProductActivityJournalDraftCharge]

	@Id bigint,
	@CreatedTimestamp datetime,
	@SubscriptionProductActivityJournalId bigint,
	@DraftChargeId bigint,
	@DeltaQuantity decimal,
	@ChargeOrder int
AS
SET NOCOUNT ON
	UPDATE [SubscriptionProductActivityJournalDraftCharge] SET 
		[CreatedTimestamp] = @CreatedTimestamp,
		[SubscriptionProductActivityJournalId] = @SubscriptionProductActivityJournalId,
		[DraftChargeId] = @DraftChargeId,
		[DeltaQuantity] = @DeltaQuantity,
		[ChargeOrder] = @ChargeOrder
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

