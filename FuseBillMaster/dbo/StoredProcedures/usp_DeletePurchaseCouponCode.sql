CREATE PROC [dbo].[usp_DeletePurchaseCouponCode]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [PurchaseCouponCode]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

