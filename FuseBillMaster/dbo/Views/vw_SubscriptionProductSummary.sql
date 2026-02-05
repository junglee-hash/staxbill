
CREATE VIEW [dbo].[vw_SubscriptionProductSummary]
AS
SELECT Id, AccountId, SubscriptionId, SortOrder, Code, Name, ProductType, Quantity, UnitPrice, Included, Amount, CASE WHEN Max = 999999999999999999.999999 THEN NULL ELSE Max END AS Max, Min
FROM     (SELECT Id, SubscriptionId, Code, Name, SortOrder, ProductType, PricingModelTypeId, CASE WHEN PricingModelTypeId IN (1, 2) THEN CASE WHEN Quantity <= Max AND 
                                    Quantity > Min THEN Quantity - Min WHEN Quantity >= Max THEN Max - Min ELSE 0 END WHEN PricingModelTypeId = 3 THEN CASE WHEN Quantity <= Max AND 
                                    Quantity > Min THEN 1 ELSE 0 END WHEN PricingModelTypeId = 4 THEN CASE WHEN Quantity <= Max AND Quantity > Min THEN Quantity ELSE 0 END ELSE 0 END AS Quantity, UnitPrice, Amount, Included, 
                                    AccountId, Max, Min
                  FROM      (SELECT sp.Id, sp.SubscriptionId, pt.SortOrder, sp.Included, sp.Amount, sp.PlanProductCode as Code, COALESCE (spo.Name, sp.PlanProductName) AS Name, sp.PlanProductDescription as Description, pt.Name AS ProductType, sp.Quantity, sp.PricingModelTypeId, 
                                                       COALESCE (pro.Min, sppr.Min) AS Min, CASE WHEN COALESCE (pro.Max, sppr.Max) IS NULL THEN 999999999999999999.999999 ELSE COALESCE (pro.Max, sppr.Max) END AS Max, COALESCE (pro.Price, 
                                                       sppr.Amount) AS UnitPrice, c.AccountId
                                     FROM      dbo.SubscriptionProduct AS sp INNER JOIN
												dbo.SubscriptionProductPriceRange sppr ON sp.Id = sppr.SubscriptionProductId INNER JOIN
                                                       dbo.Subscription AS s ON s.Id = sp.SubscriptionId INNER JOIN
                                                       dbo.Customer AS c ON c.Id = s.CustomerId INNER JOIN
                                                       Lookup.ProductType AS pt ON pt.Id = sp.ProductTypeId LEFT OUTER JOIN
                                                       dbo.PricingModelOverride AS pmo ON pmo.Id = sp.Id LEFT OUTER JOIN
                                                       dbo.PriceRangeOverride AS pro ON pmo.Id = pro.PricingModelOverrideId LEFT OUTER JOIN
                                                       dbo.SubscriptionOverride AS so ON so.Id = sp.SubscriptionId LEFT OUTER JOIN
                                                       dbo.SubscriptionProductOverride AS spo ON spo.Id = sp.Id
                                     WHERE   (sp.StatusId <> 2) AND s.IsDeleted = 0) AS Data) AS SubscriptionProducts

GO

