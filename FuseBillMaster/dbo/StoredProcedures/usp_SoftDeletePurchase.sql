CREATE PROCEDURE [dbo].[usp_SoftDeletePurchase]
	@Id bigint
AS
SET NOCOUNT ON

UPDATE [Purchase]
SET IsDeleted = 1,
	ModifiedTimestamp = GETUTCDATE()
WHERE [Id] = @Id

UPDATE [pi]
	SET [pi].StatusId = 2
FROM PurchaseProductItem ppi
INNER JOIN Purchase p ON p.Id = ppi.PurchaseId
INNER JOIN ProductItem [pi] ON [pi].id = ppi.Id
WHERE p.Id = @Id

SET NOCOUNT OFF

GO

