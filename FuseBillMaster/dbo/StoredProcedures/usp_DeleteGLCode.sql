CREATE PROC [dbo].[usp_DeleteGLCode]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [GLCode]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

