CREATE PROC [dbo].[usp_UpdateSubscriptionProductActivityJournalCharge]

	@Id bigint,
	@CreatedTimestamp datetime,
	@SubscriptionProductActivityJournalId bigint,
	@ChargeId bigint,
	@DeltaQuantity decimal,
	@ChargeOrder int
AS
SET NOCOUNT ON
	UPDATE [SubscriptionProductActivityJournalCharge] SET 
		[CreatedTimestamp] = @CreatedTimestamp,
		[SubscriptionProductActivityJournalId] = @SubscriptionProductActivityJournalId,
		[ChargeId] = @ChargeId,
		[DeltaQuantity] = @DeltaQuantity,
		[ChargeOrder] = @ChargeOrder
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

