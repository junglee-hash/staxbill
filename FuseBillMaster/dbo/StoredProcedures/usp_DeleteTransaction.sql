CREATE PROC [dbo].[usp_DeleteTransaction]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [Transaction]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

