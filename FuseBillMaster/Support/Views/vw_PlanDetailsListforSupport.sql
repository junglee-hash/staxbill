
CREATE VIEW [Support].[vw_PlanDetailsListforSupport]
AS
SELECT					 pr.PlanId, lps.Name AS PlanStatus, pla.AccountId, pla.Name AS PlanName, li.Name AS PlanInterval, pf.NumberOfIntervals, pp.Id AS PlanProductId, lpps.Name AS PlanProductStatus, 
                         pp.Name AS PlanProductName, pp.Code AS PlanProductCode, lpmt.Name AS PricingModelType, lprt.Name AS PlanProductResetType, qlctt.Name AS QuantityChargeTimingType, 
                         rlctt.Name AS RecurChargeTimingType, pocc.RecurProratePositiveQuantity, pocc.RecurProrateNegativeQuantity, pocc.RecurReverseChargeNegativeQuantity, pocc.QuantityProratePositiveQuantity, 
                         pocc.QuantityProrateNegativeQuantity, pocc.QuantityReverseChargeNegativeQuantity, occ.IsEarnedImmediately, eli.Name AS EarningInterval, occ.EarningNumberOfInterval AS EarningNumberOfIntervals, 
                         qr.Min AS MinPriceRange, qr.Max AS MaxPriceRange, pri.Amount AS PriceRangeAmount, lc.IsoName AS Currency
FROM            dbo.PlanFrequency AS pf WITH (nolock) INNER JOIN
                         Lookup.Interval AS li WITH (nolock) ON pf.Interval = li.Id INNER JOIN
                         dbo.PlanRevision AS pr WITH (nolock) ON pf.PlanRevisionId = pr.Id AND pr.IsActive = 1 INNER JOIN
                         dbo.PlanProduct AS pp WITH (nolock) ON pp.PlanRevisionId = pr.Id INNER JOIN
                         dbo.[Plan] AS pla WITH (nolock) ON pr.PlanId = pla.Id INNER JOIN
                         dbo.PlanOrderToCashCycle AS pocc WITH (nolock) ON pp.Id = pocc.PlanProductId AND pf.Id = pocc.PlanFrequencyId INNER JOIN
                         dbo.OrderToCashCycle AS occ WITH (nolock) ON pocc.Id = occ.Id INNER JOIN
                         dbo.QuantityRange AS qr WITH (nolock) ON occ.Id = qr.OrderToCashCycleId INNER JOIN
                         dbo.Price AS pri WITH (nolock) ON qr.Id = pri.QuantityRangeId INNER JOIN
                         Lookup.Currency AS lc WITH (nolock) ON pri.CurrencyId = lc.Id INNER JOIN
                         dbo.AccountPreference AS ap WITH (nolock) ON pla.AccountId = ap.Id INNER JOIN
                         Lookup.ChargeTimingType AS qlctt WITH (nolock) ON pocc.QuantityChargeTimingTypeId = qlctt.Id INNER JOIN
                         Lookup.ChargeTimingType AS rlctt WITH (nolock) ON pocc.RecurChargeTimingTypeId = rlctt.Id INNER JOIN
                         Lookup.PricingModelType AS lpmt WITH (nolock) ON occ.PricingModelTypeId = lpmt.Id LEFT OUTER JOIN
                         Lookup.Interval AS eli WITH (nolock) ON occ.EarningInterval = eli.Id INNER JOIN
                         Lookup.ProductResetType AS lprt WITH (nolock) ON pp.ResetTypeId = lprt.Id INNER JOIN
                         Lookup.PlanStatus AS lps WITH (nolock) ON pla.StatusId = lps.Id INNER JOIN
                         Lookup.PlanProductStatus AS lpps WITH (nolock) ON pp.StatusId = lpps.Id

GO

