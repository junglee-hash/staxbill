 
 
CREATE PROC [dbo].[usp_InsertSubscriptionProductActivityJournalCharge]

	@CreatedTimestamp datetime,
	@SubscriptionProductActivityJournalId bigint,
	@ChargeId bigint,
	@DeltaQuantity decimal,
	@ChargeOrder int
AS
SET NOCOUNT ON
	INSERT INTO [SubscriptionProductActivityJournalCharge] (
		[CreatedTimestamp],
		[SubscriptionProductActivityJournalId],
		[ChargeId],
		[DeltaQuantity],
		[ChargeOrder]
	)
	VALUES (
		@CreatedTimestamp,
		@SubscriptionProductActivityJournalId,
		@ChargeId,
		@DeltaQuantity,
		@ChargeOrder
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

