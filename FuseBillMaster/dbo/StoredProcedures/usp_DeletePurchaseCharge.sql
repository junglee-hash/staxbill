CREATE PROC [dbo].[usp_DeletePurchaseCharge]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [PurchaseCharge]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

