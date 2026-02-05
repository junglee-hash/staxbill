CREATE PROC [dbo].[usp_DeletePrice]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [Price]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

