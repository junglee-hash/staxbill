CREATE PROC [dbo].[usp_DeleteServiceJob]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [ServiceJob]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

