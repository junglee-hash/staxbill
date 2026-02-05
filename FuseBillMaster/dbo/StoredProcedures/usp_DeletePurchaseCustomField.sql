CREATE PROC [dbo].[usp_DeletePurchaseCustomField]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [PurchaseCustomField]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

