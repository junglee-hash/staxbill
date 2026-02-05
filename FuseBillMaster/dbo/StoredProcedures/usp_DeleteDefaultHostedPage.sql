CREATE PROC [dbo].[usp_DeleteDefaultHostedPage]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [DefaultHostedPage]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

