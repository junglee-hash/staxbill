
CREATE PROCEDURE [dbo].[usp_QBOApplyProductMappingToCustomer]
	@CustomerId BIGINT
AS

UPDATE ch
SET ch.QuickBooksItemId = pr.QuickBooksItemId
,ch.QuickBooksRecordType = pr.QuickBooksRecordType
FROM Charge ch
INNER JOIN [Transaction] t ON t.Id = ch.Id
INNER JOIN Customer c ON c.Id = t.CustomerId
LEFT JOIN PurchaseCharge pc ON pc.Id = ch.Id
LEFT JOIN Purchase p ON p.Id = pc.PurchaseId
LEFT JOIN SubscriptionProductCharge spc ON spc.Id = ch.ID
LEFT JOIN SubscriptionProduct sp ON sp.Id = spc.SubscriptionProductId
INNER JOIN Product pr ON pr.Id = COALESCE(sp.ProductId,p.ProductId)
WHERE t.CustomerId = @CustomerId
	AND pr.QuickBooksItemId IS NOT NULL
	AND t.EffectiveTimestamp >= c.QuickBooksSyncTimestamp

UPDATE ch
SET ch.QuickBooksClassId = s.QuickBooksClassId
FROM Charge ch
INNER JOIN ChargeGroup cg ON cg.Id = ch.ChargeGroupId
INNER JOIN Subscription s ON s.Id = cg.SubscriptionId
INNER JOIN [Transaction] t ON t.Id = ch.Id
INNER JOIN Customer c ON c.Id = t.CustomerId
WHERE t.CustomerId = @CustomerId
	AND c.QuickBooksId IS NOT NULL
	AND t.EffectiveTimestamp >= c.QuickBooksSyncTimestamp

GO

