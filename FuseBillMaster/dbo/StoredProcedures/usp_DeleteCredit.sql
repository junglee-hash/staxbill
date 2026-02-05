CREATE PROC [dbo].[usp_DeleteCredit]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [Credit]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

