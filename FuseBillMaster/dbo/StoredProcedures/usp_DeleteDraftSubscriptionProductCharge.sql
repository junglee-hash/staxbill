CREATE PROC [dbo].[usp_DeleteDraftSubscriptionProductCharge]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [DraftSubscriptionProductCharge]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

