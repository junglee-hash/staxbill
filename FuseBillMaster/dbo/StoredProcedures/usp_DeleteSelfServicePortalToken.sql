CREATE PROC [dbo].[usp_DeleteSelfServicePortalToken]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [SelfServicePortalToken]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

