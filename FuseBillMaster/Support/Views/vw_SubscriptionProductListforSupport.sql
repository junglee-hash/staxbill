CREATE VIEW [Support].[vw_SubscriptionProductListforSupport]
AS
SELECT         s.Id AS SubscriptionId, c.AccountId, s.PlanName AS SubscriptionName, so.Name AS SubscriptionNameOverride, li.Name AS PlanInterval, s.NumberOfIntervals, lss.Name AS SubscriptionStatus, 
                         dbo.fn_GetTimezoneTime(s.CreatedTimestamp, ap.TimezoneId) AS CreatedTimestamp, dbo.fn_GetTimezoneTime(s.ActivationTimestamp, ap.TimezoneId) AS ActivationTimestamp, 
                         dbo.fn_GetTimezoneTime(s.ScheduledActivationTimestamp, ap.TimezoneId) AS ScheduledActivationTimestamp, dbo.fn_GetTimezoneTime(s.ProvisionedTimestamp, ap.TimezoneId) AS ProvisionedTimestamp, 
                         dbo.fn_GetTimezoneTime(s.CancellationTimestamp, ap.TimezoneId) AS CancellationTimestamp, s.RemainingInterval AS RemainingIntervalsBeforeExpiration, s.AutoApplyCatalogChanges, 
                         s.MonthlyRecurringRevenue, s.NetMRR, s.SalesforceId AS SubscriptionSalesforceId, s.NetsuiteId AS SubscriptionNetsuiteId, s.PlanId, sp.Id AS SubscriptionProductId, sp.PlanProductName AS SubscriptionProductName, 
                         spo.Name AS SubscriptionProductOverrideName, sp.PlanProductCode AS SubscriptionProductCode, sp.Included AS SubscriptionProductIncluded, dbo.fn_GetTimezoneTime(sp.StartDate, ap.TimezoneId) 
                         AS SubscriptionProductStartDate, sp.IsTrackingItems, lpmt.Name AS PricingModelType, lprt.Name AS SubscriptionProductResetType, sp.Quantity AS SubscriptionProductQuantity, sp.MaxQuantity, 
                         sp.IsFixed AS FixedQuantity, sp.SalesforceId AS SubscriptionProductSalesforceId, sp.NetsuiteId AS SubscriptionProductNetsuiteId, qlctt.Name AS QuantityChargeTimingType, 
                         rlctt.Name AS RecurChargeTimingType, sp.RecurProratePositiveQuantity, sp.RecurProrateNegativeQuantity, sp.RecurReverseChargeNegativeQuantity, sp.QuantityProratePositiveQuantity, 
                         sp.QuantityProrateNegativeQuantity, sp.QuantityReverseChargeNegativeQuantity, sp.IsEarnedImmediately, eli.Name AS EarningInterval, sp.EarningNumberOfInterval AS EarningNumberOfIntervals, 
                         sppr.Min AS MinPriceRange, sppr.Max AS MaxPriceRange, sppr.Amount AS PriceRangeAmount, pro.Price AS PriceRangeOverrideAmount, lc.IsoName AS Currency
FROM            dbo.Subscription AS s WITH (nolock) LEFT OUTER JOIN
                         dbo.SubscriptionOverride AS so WITH (nolock) ON s.Id = so.Id INNER JOIN
						 dbo.Customer c WITH (NOLOCK) ON c.Id = s.CustomerId INNER JOIN
                         Lookup.Interval AS li ON s.IntervalId = li.Id INNER JOIN
                         Lookup.SubscriptionStatus AS lss ON s.StatusId = lss.Id INNER JOIN
                         dbo.SubscriptionProduct AS sp WITH (nolock) ON s.Id = sp.SubscriptionId INNER JOIN
						 dbo.SubscriptionProductPriceRange sppr WITH (NOLOCK) ON sp.Id = sppr.SubscriptionProductId INNER JOIN
                         Lookup.Currency AS lc WITH (nolock) ON c.CurrencyId = lc.Id INNER JOIN
                         dbo.AccountPreference AS ap WITH (nolock) ON c.AccountId = ap.Id INNER JOIN
                         Lookup.ChargeTimingType AS qlctt WITH (nolock) ON sp.QuantityChargeTimingTypeId = qlctt.Id INNER JOIN
                         Lookup.ChargeTimingType AS rlctt WITH (nolock) ON sp.RecurChargeTimingTypeId = rlctt.Id INNER JOIN
                         Lookup.PricingModelType AS lpmt WITH (nolock) ON sp.PricingModelTypeId = lpmt.Id LEFT OUTER JOIN
                         Lookup.Interval AS eli WITH (nolock) ON sp.EarningIntervalId = eli.Id INNER JOIN
                         Lookup.ProductResetType AS lprt WITH (nolock) ON sp.ResetTypeId = lprt.Id LEFT OUTER JOIN
                         dbo.SubscriptionProductOverride AS spo WITH (nolock) ON sp.Id = spo.Id LEFT OUTER JOIN
                         dbo.PricingModelOverride AS pmo WITH (nolock) ON sp.Id = pmo.Id LEFT OUTER JOIN
                         dbo.PriceRangeOverride AS pro WITH (nolock) ON pmo.Id = pro.PricingModelOverrideId AND sppr.Min = pro.Min

GO

