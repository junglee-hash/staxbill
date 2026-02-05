CREATE PROC [dbo].[usp_DeleteHostedPageSelfServicePortal]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [HostedPageSelfServicePortal]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

