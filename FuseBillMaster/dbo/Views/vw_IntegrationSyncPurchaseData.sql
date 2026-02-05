


CREATE VIEW [dbo].[vw_IntegrationSyncPurchaseData]
AS
SELECT DISTINCT 
                  TOP (100) PERCENT sfbr.IntegrationSynchBatchId as BatchId, p.SalesforceId, cus.SalesforceId AS AccountSalesforceId, 
				  p.Id, p.CustomerId, p.ProductId, p.Quantity, p.Name, p.[Description], 
                  ps.Name as [Status], pmt.Name as PricingModelType, p.IsTrackingItems, 
				  LEFT(p.Name, 80) as SalesforceName, prod.Code as ProductCode,
				  p.Id as PurchaseId, p.PurchaseTimestamp as PurchasedTimestamp, p.CreatedTimestamp,
				  CASE WHEN p.Quantity > 0 THEN p.TaxableAmount / p.Quantity ELSE 0 END as UnitPrice,
				  cus.AccountId, p.Amount
FROM     dbo.Purchase p 
INNER JOIN Lookup.PurchaseStatus ps ON ps.Id = p.StatusId
INNER JOIN Lookup.PricingModelType pmt ON pmt.Id = p.PricingModelTypeId
INNER JOIN Product prod ON prod.Id = p.ProductId
INNER JOIN dbo.IntegrationSynchBatchRecord AS sfbr ON sfbr.EntityId = p.Id 
INNER JOIN dbo.IntegrationSynchBatch AS sfb ON sfbr.IntegrationSynchBatchId = sfb.Id 
INNER JOIN dbo.Customer AS cus ON cus.Id = p.CustomerId
WHERE  (sfbr.EntityTypeId = 21) AND (sfb.StatusId NOT IN (4, 5))
ORDER BY p.Id

GO

