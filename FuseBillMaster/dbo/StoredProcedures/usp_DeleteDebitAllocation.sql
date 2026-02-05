CREATE PROC [dbo].[usp_DeleteDebitAllocation]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [DebitAllocation]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

