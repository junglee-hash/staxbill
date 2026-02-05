
CREATE   procedure [dbo].[usp_WipeSalesforceCatalogIds]
	@AccountId bigint
AS

SET NOCOUNT ON

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

UPDATE AccountSalesforceConfiguration
SET SalesforceCatalogSyncStatusId = 1
WHERE Id = @AccountId

UPDATE Account
SET ModifiedTimestamp = GETUTCDATE()
WHERE Id = @AccountId

SET NOCOUNT OFF

GO

