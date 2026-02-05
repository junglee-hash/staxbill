CREATE procedure [dbo].[usp_ClearSalesforceIds]
@AccountId bigint
AS

SET NOCOUNT ON 

UPDATE Customer
	SET SalesforceId = NULL
WHERE AccountId = @AccountId

UPDATE s
SET SalesforceId = NULL 
FROM Subscription s 
INNER JOIN Customer c ON s.CustomerId = c.Id 
WHERE c.AccountId = @AccountId

UPDATE sp
SET SalesforceId = NULL 
FROM SubscriptionProduct sp
INNER JOIN Subscription s ON sp.SubscriptionId = s.Id 
INNER JOIN Customer c ON s.CustomerId = c.Id 
WHERE c.AccountId = @AccountId

UPDATE Invoice
	SET SalesforceId = NULL
WHERE AccountId = @AccountId

UPDATE p
SET SalesforceId = NULL 
FROM Purchase p 
INNER JOIN Customer c ON p.CustomerId = c.Id 
WHERE c.AccountId = @AccountId

UPDATE Product
SET SalesforceId = NULL
WHERE AccountId = @AccountId

UPDATE pf
SET SalesforceId = NULL
FROM PlanFrequency pf
INNER JOIN PlanRevision pr ON pf.PlanRevisionId = pr.Id
INNER JOIN [Plan] p ON pr.PlanId = p.Id
WHERE p.AccountId = @AccountId

UPDATE price
SET SalesforceId = NULL
FROM Price price
INNER JOIN QuantityRange qr ON price.QuantityRangeId = qr.Id
INNER JOIN Product p ON qr.OrderToCashCycleId = p.OrderToCashCycleId
WHERE p.AccountId = @AccountId

DELETE FROM SalesforceSyncStatus
WHERE AccountId = @AccountId

GO

