 
 
CREATE PROC [dbo].[usp_InsertGrandfatheringSubscriptionChangeLog]

	@SubscriptionId bigint,
	@OldPlanFrequencyId bigint,
	@NewPlanFrequencyId bigint,
	@CreatedTimestamp datetime
AS
SET NOCOUNT ON
	INSERT INTO [GrandfatheringSubscriptionChangeLog] (
		[SubscriptionId],
		[OldPlanFrequencyId],
		[NewPlanFrequencyId],
		[CreatedTimestamp]
	)
	VALUES (
		@SubscriptionId,
		@OldPlanFrequencyId,
		@NewPlanFrequencyId,
		@CreatedTimestamp
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

