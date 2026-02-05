CREATE PROC [dbo].[usp_DeleteSubscriptionProductActivityJournal]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [SubscriptionProductActivityJournal]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

