CREATE PROC [dbo].[usp_DeleteRefund]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [Refund]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

