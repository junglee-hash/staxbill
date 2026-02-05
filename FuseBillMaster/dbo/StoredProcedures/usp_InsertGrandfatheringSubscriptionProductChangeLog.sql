 
 
CREATE PROC [dbo].[usp_InsertGrandfatheringSubscriptionProductChangeLog]

	@SubscriptionProductId bigint,
	@OldPlanProductId bigint,
	@NewPlanProductId bigint,
	@CreatedTimestamp datetime,
	@OldStatusId int,
	@NewStatusId int
AS
SET NOCOUNT ON
	INSERT INTO [GrandfatheringSubscriptionProductChangeLog] (
		[SubscriptionProductId],
		[OldPlanProductId],
		[NewPlanProductId],
		[CreatedTimestamp],
		[OldStatusId],
		[NewStatusId]
	)
	VALUES (
		@SubscriptionProductId,
		@OldPlanProductId,
		@NewPlanProductId,
		@CreatedTimestamp,
		@OldStatusId,
		@NewStatusId
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

