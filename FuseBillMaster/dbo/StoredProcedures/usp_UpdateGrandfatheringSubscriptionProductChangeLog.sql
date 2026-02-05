CREATE PROC [dbo].[usp_UpdateGrandfatheringSubscriptionProductChangeLog]

	@Id bigint,
	@SubscriptionProductId bigint,
	@OldPlanProductId bigint,
	@NewPlanProductId bigint,
	@CreatedTimestamp datetime,
	@OldStatusId int,
	@NewStatusId int
AS
SET NOCOUNT ON
	UPDATE [GrandfatheringSubscriptionProductChangeLog] SET 
		[SubscriptionProductId] = @SubscriptionProductId,
		[OldPlanProductId] = @OldPlanProductId,
		[NewPlanProductId] = @NewPlanProductId,
		[CreatedTimestamp] = @CreatedTimestamp,
		[OldStatusId] = @OldStatusId,
		[NewStatusId] = @NewStatusId
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

