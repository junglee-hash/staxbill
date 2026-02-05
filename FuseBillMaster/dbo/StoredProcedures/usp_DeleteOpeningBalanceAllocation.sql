CREATE PROC [dbo].[usp_DeleteOpeningBalanceAllocation]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [OpeningBalanceAllocation]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

