CREATE PROC [dbo].[usp_DeleteDebit]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [Debit]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

