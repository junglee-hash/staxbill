 
 
CREATE PROC [dbo].[usp_InsertSalesforceOneTimeAuthorizationToken]

	@AuthorizationToken uniqueidentifier,
	@AccountId bigint,
	@CreatedTimestamp datetime
AS
SET NOCOUNT ON
	INSERT INTO [SalesforceOneTimeAuthorizationToken] (
		[AuthorizationToken],
		[AccountId],
		[CreatedTimestamp]
	)
	VALUES (
		@AuthorizationToken,
		@AccountId,
		@CreatedTimestamp
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

