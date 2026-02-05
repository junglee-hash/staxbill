CREATE PROC [dbo].[usp_UpdateSubscriptionStatusJournal]

	@Id bigint,
	@SubscriptionId bigint,
	@StatusId int,
	@CreatedTimestamp datetime
AS
SET NOCOUNT ON
	UPDATE [SubscriptionStatusJournal] SET 
		[SubscriptionId] = @SubscriptionId,
		[StatusId] = @StatusId,
		[CreatedTimestamp] = @CreatedTimestamp
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

