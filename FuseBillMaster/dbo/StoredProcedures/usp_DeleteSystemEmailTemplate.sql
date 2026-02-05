CREATE PROC [dbo].[usp_DeleteSystemEmailTemplate]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [SystemEmailTemplate]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

