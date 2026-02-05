CREATE PROC [dbo].[usp_UpdateGrandfatheringSubscriptionChangeLog]

	@Id bigint,
	@SubscriptionId bigint,
	@OldPlanFrequencyId bigint,
	@NewPlanFrequencyId bigint,
	@CreatedTimestamp datetime
AS
SET NOCOUNT ON
	UPDATE [GrandfatheringSubscriptionChangeLog] SET 
		[SubscriptionId] = @SubscriptionId,
		[OldPlanFrequencyId] = @OldPlanFrequencyId,
		[NewPlanFrequencyId] = @NewPlanFrequencyId,
		[CreatedTimestamp] = @CreatedTimestamp
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

