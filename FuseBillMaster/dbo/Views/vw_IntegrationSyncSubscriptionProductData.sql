
CREATE VIEW [dbo].[vw_IntegrationSyncSubscriptionProductData]
AS
SELECT DISTINCT 
                  TOP (100) PERCENT sfbr.IntegrationSynchBatchId as BatchId, sp.SalesforceId, sub.SalesforceId AS SubscriptionSalesforceId, cus.SalesforceId AS AccountSalesforceId, 
				  sp.NetsuiteId, sub.NetsuiteId as SubscriptionNetsuiteId, cus.NetsuiteId as CustomerNetsuiteId,
				  sp.Id, 
                  sp.Amount, CASE WHEN (sp.Included) = 1 THEN 'true' ELSE 'false' END AS IsIncluded, CASE WHEN (sp.IsRecurring) = 1 THEN 'true' ELSE 'false' END AS IsRecurring, 
                  CASE WHEN (sp.IsTrackingItems) = 1 THEN 'true' ELSE 'false' END AS IsTrackingItems, 
				  CASE WHEN afc.MrrDisplayTypeId = 1 THEN sp.MonthlyRecurringRevenue ELSE sp.CurrentMrr END AS MonthlyRecurringRevenue, 
				  CASE WHEN afc.MrrDisplayTypeId = 1 THEN sp.NetMRR ELSE sp.CurrentNetMrr END AS NetMrr ,
				  ISNULL(spoverride.Description, sp.PlanProductDescription) 
                  AS Description, ISNULL(spoverride.Name, sp.PlanProductName) AS Name, ISNULL(spoverride.Name, sp.PlanProductName) AS ProductName, sp.Quantity, sp.StartDate, sub.Id AS SubscriptionId, 
                  CASE WHEN
                      (SELECT Id
                       FROM      Lookup.PricingModelType
                       WHERE   Id = sp.PricingModelTypeId) = 1 THEN ISNULL(proverride.Price,
                      (SELECT Amount
                       FROM      dbo.SubscriptionProductPriceRange sppr
                       WHERE   SubscriptionProductId = sp.Id)) END AS UnitPrice, 
					   cus.AccountId
FROM     dbo.SubscriptionProduct sp INNER JOIN
                  dbo.IntegrationSynchBatchRecord AS sfbr ON sfbr.EntityId = sp.Id INNER JOIN
                  dbo.IntegrationSynchBatch AS sfb ON sfbr.IntegrationSynchBatchId = sfb.Id INNER JOIN
                  dbo.Subscription AS sub ON sub.Id = sp.SubscriptionId INNER JOIN
                  dbo.Customer AS cus ON cus.Id = sub.CustomerId INNER JOIN
				  dbo.AccountFeatureConfiguration AS afc ON afc.Id = cus.AccountId LEFT OUTER JOIN
                  dbo.PricingModelOverride AS pmOverride ON pmOverride.Id = sp.Id LEFT OUTER JOIN
                  dbo.PriceRangeOverride AS proverride ON proverride.PricingModelOverrideId = pmOverride.Id LEFT OUTER JOIN
                  dbo.SubscriptionProductOverride AS spoverride ON spoverride.Id = sp.Id
WHERE  (sfbr.EntityTypeId = 14) AND (sfb.StatusId NOT IN (4, 5))
ORDER BY sp.Id

GO

