CREATE PROC [dbo].[usp_DeleteReverseTax]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [ReverseTax]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

