CREATE PROC [dbo].[usp_DeleteReverseEarning]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [ReverseEarning]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

