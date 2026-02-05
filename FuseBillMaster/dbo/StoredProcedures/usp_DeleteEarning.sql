CREATE PROC [dbo].[usp_DeleteEarning]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [Earning]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

