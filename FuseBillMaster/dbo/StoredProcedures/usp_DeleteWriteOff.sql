CREATE PROC [dbo].[usp_DeleteWriteOff]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [WriteOff]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

