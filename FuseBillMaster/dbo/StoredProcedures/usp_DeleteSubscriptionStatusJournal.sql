CREATE PROC [dbo].[usp_DeleteSubscriptionStatusJournal]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [SubscriptionStatusJournal]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

