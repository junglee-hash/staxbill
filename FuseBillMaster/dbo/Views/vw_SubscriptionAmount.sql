CREATE VIEW [dbo].[vw_SubscriptionAmount]
AS
SELECT SubscriptionProductId, SubscriptionId, CustomerId, AccountId, CASE WHEN SubscriptionProductStatusId <> 1 THEN 0 WHEN RawAmount - SUM(isnull(TotalDiscount, 0)) 
                  < 0 THEN 0 ELSE RawAmount - SUM(isnull(TotalDiscount, 0)) END AS Amount
FROM     (SELECT SubscriptionProductId, SubscriptionProductStatusId, SubscriptionId, CustomerId, AccountId, Amount AS RawAmount,
                                       (SELECT sum(DiscountAmount) as DiscountAmount FROM (SELECT CASE WHEN DiscountTypeId IN (1, 2) THEN CASE WHEN DiscountTypeId = 1 THEN CAST(results.Amount * spd.amount / 100 AS Decimal(10, 2)) ELSE CAST(spd.Amount AS Decimal(10, 2)) 
                                                           END ELSE 0 END AS DiscountAmount
                                         FROM      dbo.SubscriptionProductDiscount AS spd
                                         WHERE   (Results.SubscriptionProductId = SubscriptionProductId) AND (ISNULL(RemainingUsage, 999) > 0) AND (RemainingUsagesUntilStart = 0)) AS DiscountedAmount) as TotalDiscount
                  FROM      (SELECT SubscriptionProductId, SubscriptionProductStatusId, SubscriptionId, CustomerId, AccountId, CAST(ISNULL(SUM(Amount * UnitsToCharge), 0) AS Decimal(10, 2)) AS Amount
                                     FROM      (SELECT SubscriptionProductId, SubscriptionProductStatusId, SubscriptionId, CustomerId, Amount, Interval, NumberOfIntervals, CASE WHEN PricingModelTypeId IN (1, 2) 
                                                                          THEN CASE WHEN Quantity < Max AND 
                                                                          Quantity >= Min THEN Quantity - Min WHEN Quantity > Max THEN Max - Min ELSE 0 END WHEN PricingModelTypeId = 3 THEN CASE WHEN Quantity < Max AND 
                                                                          Quantity >= Min THEN 1 ELSE 0 END WHEN PricingModelTypeId = 4 THEN CASE WHEN Quantity < Max AND Quantity >= Min THEN Quantity ELSE 0 END ELSE 0 END AS UnitsToCharge, 
                                                                          AccountId
                                                        FROM      (SELECT sp.Id AS SubscriptionProductId, sp.StatusId AS SubscriptionProductStatusId, sp.Quantity, COALESCE (pro.Min, sppr.Min) AS Min, CASE WHEN COALESCE (pro.Max, sppr.Max) IS NULL 
                                                                                             THEN 999999999999999999.999999 ELSE COALESCE (pro.Max, sppr.Max) END AS Max, COALESCE (pro.Price, sppr.Amount) AS Amount, s.IntervalId as Interval, s.NumberOfIntervals, 
                                                                                             c.Id AS CustomerId, sp.SubscriptionId, c.AccountId, sp.PricingModelTypeId
                                                                           FROM      dbo.SubscriptionProduct AS sp INNER JOIN
																					dbo.SubscriptionProductPriceRange sppr ON sp.Id = sppr.SubscriptionProductId INNER JOIN
                                                                                             dbo.Subscription AS s ON sp.SubscriptionId = s.Id INNER JOIN
                                                                                             dbo.Customer AS c ON s.CustomerId = c.Id INNER JOIN
                                                                                             dbo.CustomerStatusJournal AS csj ON c.Id = csj.CustomerId AND csj.IsActive = 1 LEFT OUTER JOIN
                                                                                             dbo.PricingModelOverride AS pmo ON sp.Id = pmo.Id LEFT OUTER JOIN
                                                                                             dbo.PriceRangeOverride AS pro ON pmo.Id = pro.PricingModelOverrideId
                                                                           WHERE   (sp.Included = 1) AND (s.StatusId = 2)) AS Data) AS Amount
                                     GROUP BY NumberOfIntervals, SubscriptionProductId, SubscriptionProductStatusId, CustomerId, SubscriptionId, AccountId) AS Results
                  GROUP BY SubscriptionProductId, SubscriptionProductStatusId, SubscriptionId, CustomerId, AccountId, Amount) AS more
GROUP BY SubscriptionProductId, SubscriptionProductStatusId, SubscriptionId, CustomerId, AccountId, RawAmount

GO

