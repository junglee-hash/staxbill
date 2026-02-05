CREATE PROC [dbo].[usp_DeleteAccountWebhooksKey]
	@AccountId bigint
AS
SET NOCOUNT ON

DELETE FROM [AccountWebhooksKey]
WHERE [AccountId] = @AccountId

SET NOCOUNT OFF

GO

