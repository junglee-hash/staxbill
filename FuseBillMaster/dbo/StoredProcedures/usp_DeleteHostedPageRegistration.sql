CREATE PROC [dbo].[usp_DeleteHostedPageRegistration]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [HostedPageRegistration]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

