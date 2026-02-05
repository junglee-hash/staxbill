 
 
CREATE PROC [dbo].[usp_InsertAccountWebhooksKey]

	@AccountId bigint,
	@WebhooksKey nvarchar(255),
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime
AS
SET NOCOUNT ON
	INSERT INTO [AccountWebhooksKey] (
		[AccountId],
		[WebhooksKey],
		[CreatedTimestamp],
		[ModifiedTimestamp]
	)
	VALUES (
		@AccountId,
		@WebhooksKey,
		@CreatedTimestamp,
		@ModifiedTimestamp
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

