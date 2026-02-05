CREATE PROC [dbo].[usp_DeleteRefundNote]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [RefundNote]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

