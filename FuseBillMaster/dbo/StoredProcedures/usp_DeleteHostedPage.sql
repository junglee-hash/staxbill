CREATE PROC [dbo].[usp_DeleteHostedPage]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [HostedPage]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

