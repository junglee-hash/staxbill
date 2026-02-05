 
 
CREATE PROC [dbo].[usp_InsertSubscriptionProductActivityJournalDraftCharge]

	@CreatedTimestamp datetime,
	@SubscriptionProductActivityJournalId bigint,
	@DraftChargeId bigint,
	@DeltaQuantity decimal,
	@ChargeOrder int
AS
SET NOCOUNT ON
	INSERT INTO [SubscriptionProductActivityJournalDraftCharge] (
		[CreatedTimestamp],
		[SubscriptionProductActivityJournalId],
		[DraftChargeId],
		[DeltaQuantity],
		[ChargeOrder]
	)
	VALUES (
		@CreatedTimestamp,
		@SubscriptionProductActivityJournalId,
		@DraftChargeId,
		@DeltaQuantity,
		@ChargeOrder
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

