CREATE PROC [dbo].[usp_DeletePurchase]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [Purchase]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

