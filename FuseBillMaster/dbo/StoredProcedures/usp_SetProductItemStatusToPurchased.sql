CREATE PROCEDURE [dbo].[usp_SetProductItemStatusToPurchased]
	@accountId bigint
AS
SET NOCOUNT ON
	UPDATE 
		ProductItem
	SET 
		StatusId = (SELECT Id FROM Lookup.SubscriptionProductItemStatus WHERE NAME = 'Purchased')
	FROM
		ProductItem pit
		JOIN Customer c
			ON pit.CustomerId = c.Id
		JOIN PurchaseProductItem ppi ON ppi.Id = pit.Id
		JOIN Purchase p ON ppi.PurchaseId = p.Id
	WHERE c.AccountId = @accountId
	AND p.StatusId = (SELECT Id FROM Lookup.PurchaseStatus WHERE NAME = 'Purchased')
	AND pit.StatusId = (SELECT Id FROM Lookup.SubscriptionProductItemStatus WHERE NAME = 'Active')
SET NOCOUNT OFF

GO

