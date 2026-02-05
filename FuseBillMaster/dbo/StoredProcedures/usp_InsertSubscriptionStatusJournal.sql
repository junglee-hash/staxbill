 
 
CREATE PROC [dbo].[usp_InsertSubscriptionStatusJournal]

	@SubscriptionId bigint,
	@StatusId int,
	@CreatedTimestamp datetime
AS
SET NOCOUNT ON
	INSERT INTO [SubscriptionStatusJournal] (
		[SubscriptionId],
		[StatusId],
		[CreatedTimestamp]
	)
	VALUES (
		@SubscriptionId,
		@StatusId,
		@CreatedTimestamp
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

