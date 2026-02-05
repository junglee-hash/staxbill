CREATE PROC [dbo].[usp_DeleteTax]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [Tax]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

