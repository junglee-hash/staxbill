CREATE PROC [dbo].[usp_DeleteSalesforceOneTimeAuthorizationToken]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [SalesforceOneTimeAuthorizationToken]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

