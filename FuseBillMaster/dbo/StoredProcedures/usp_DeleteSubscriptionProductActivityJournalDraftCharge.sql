CREATE PROC [dbo].[usp_DeleteSubscriptionProductActivityJournalDraftCharge]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [SubscriptionProductActivityJournalDraftCharge]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

