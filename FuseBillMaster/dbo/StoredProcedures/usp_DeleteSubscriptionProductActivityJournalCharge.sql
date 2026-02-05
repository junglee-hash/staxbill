CREATE PROC [dbo].[usp_DeleteSubscriptionProductActivityJournalCharge]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [SubscriptionProductActivityJournalCharge]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

