CREATE PROC [dbo].[usp_UpdateSalesforceOneTimeAuthorizationToken]

	@Id bigint,
	@AuthorizationToken uniqueidentifier,
	@AccountId bigint,
	@CreatedTimestamp datetime
AS
SET NOCOUNT ON
	UPDATE [SalesforceOneTimeAuthorizationToken] SET 
		[AuthorizationToken] = @AuthorizationToken,
		[AccountId] = @AccountId,
		[CreatedTimestamp] = @CreatedTimestamp
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

