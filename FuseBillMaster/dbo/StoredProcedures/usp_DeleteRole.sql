CREATE PROC [dbo].[usp_DeleteRole]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [Role]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

