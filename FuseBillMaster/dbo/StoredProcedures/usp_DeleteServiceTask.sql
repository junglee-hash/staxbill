CREATE PROC [dbo].[usp_DeleteServiceTask]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [ServiceTask]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

