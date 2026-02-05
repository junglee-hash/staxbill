CREATE PROC [dbo].[usp_UpdateAccountWebhooksKey]

	@AccountId bigint,
	@WebhooksKey nvarchar(255),
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime
AS
SET NOCOUNT ON
	UPDATE [AccountWebhooksKey] SET 
		[WebhooksKey] = @WebhooksKey,
		[CreatedTimestamp] = @CreatedTimestamp,
		[ModifiedTimestamp] = @ModifiedTimestamp
	WHERE [AccountId] = @AccountId

SET NOCOUNT OFF

GO

