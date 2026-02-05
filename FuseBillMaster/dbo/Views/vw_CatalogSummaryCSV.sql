
CREATE VIEW [dbo].[vw_CatalogSummaryCSV]
AS
SELECT 
	pf.Id as PlanFrequencyId,
	pr.Id as PlanRevisionId,
	pla.Id as PlanId,
	pp.Id as PlanProductId,
	pro.Id as ProductId,
	pocc.Id as PlanOrderToCashCycleId,
	otcc.Id as OrderToCashCycleId,
	case when pmt.Name = 'Pricebook' then qrp.Id else qr.Id end as QuantityRangeId,
	case when pmt.Name = 'Pricebook' then prip.ID else pri.Id end as PriceId,
	pla.AccountId,
	pla.Code as PlanCode,
	pla.Name as PlanName,
	pla.[Description] as PlanDescription,
	pla.Reference as Reference,
	i.Name as PlanFrequencyType,
	pf.NumberOfIntervals as PlanFrequencyValue,	
	pis.Name AS PlanFrequencyStatus,
	ps.Name AS PlanStatus,
	pf.RemainingInterval AS PlanRemainingInterval,	
	pp.Code as PlanProductCode,
	pp.IsIncludedByDefault as Included,
	pp.Name as PlanProductName,
	pp.[Description] as PlanProductDescription,
	pps.Name as PlanProductStatus,
	pp.Quantity,
	pp.IsTrackingItems AS Tracking,
	prt.Name AS Resetting,
	prot.Name as ProductType,
	gl.Code as GLCode,
	pp.IsFixed as FixedQuantity,
	pp.MaxQuantity,
	pp.IsOptional,
	pp.IsIncludedByDefault,
	pmt.Name as PricingModel,
	case when pmt.Name = 'Pricebook' then lcp.IsoName else lc.IsoName end as Currency,
	case when pmt.Name = 'Pricebook' then qrp.[Min] else qr.[Min] end as PriceRangeMin,
	CASE WHEN pmt.Name = 'Formula' THEN NULL when pmt.Name = 'Pricebook' then qrp.[Max] else qr.[Max] END as PriceRangeMax,
	CASE WHEN pmt.Name = 'Formula' THEN NULL when pmt.Name = 'Pricebook' then prip.Amount ELSE pri.Amount END as RangePrice,
	rlctt.Name as ChargeTimingPurchase,
	CASE WHEN qlctt.Name = 'Start of period' THEN 'Do Not Charge' ELSE qlctt.Name END as ChargeTimingQuantityChange,
	pocc.RecurProratePositiveQuantity as ProRatedPurchase,
	rlpg.Name as ProRatedPurchaseGranularity,
	pocc.QuantityProratePositiveQuantity as ProRatedQuantityChange,
	qlpg.Name as ProRatedQuantityChangeGranularity,	
	pocc.TrackPeakQuantity,
	pocc.RemainingInterval as PlanProductRemainingInterval,
	eti.Name as EarningInterval,
	ett.Name as EarningTiming,
	pp.GenerateZeroDollarCharge
FROM
dbo.PlanFrequency AS pf WITH (nolock) 
INNER JOIN dbo.PlanRevision AS pr WITH (nolock) ON pf.PlanRevisionId = pr.Id AND pr.IsActive = 1 
INNER JOIN dbo.PlanProduct AS pp WITH (nolock) ON pp.PlanRevisionId = pr.Id And pp.StatusId <> 4
INNER JOIN dbo.[Plan] AS pla WITH (nolock) ON pr.PlanId = pla.Id 
INNER JOIN dbo.Product AS pro on pro.Id = pp.ProductId
LEFT OUTER JOIN dbo.GLCode AS gl on gl.Id = COALESCE(pp.GLCodeId, pro.GLCodeId)
INNER JOIN dbo.PlanOrderToCashCycle AS pocc WITH (nolock) ON pp.Id = pocc.PlanProductId AND pf.Id = pocc.PlanFrequencyId
INNER JOIN dbo.OrderToCashCycle AS otcc on pocc.Id = otcc.Id
left join PricebookEntry pe on pe.PricebookId = pocc.PricebookId
left JOIN dbo.QuantityRange AS qr on qr.OrderToCashCycleId = otcc.Id
left join dbo.QuantityRange as qrp on qrp.OrderToCashCycleId = pe.OrderToCashCycleId
left JOIN dbo.Price AS pri on pri.QuantityRangeId = qr.Id
left JOIN dbo.Price AS prip on prip.QuantityRangeId = qrp.Id
inner JOIN Lookup.PlanStatus as ps WITH (nolock) ON pla.StatusId = ps.Id
inner JOIN Lookup.PlanProductStatus as pps WITH (nolock) ON pp.StatusId = pps.Id
left JOIN Lookup.Currency AS lc WITH (nolock) ON pri.CurrencyId = lc.Id
left JOIN Lookup.Currency AS lcp WITH (nolock) ON prip.CurrencyId = lcp.Id
INNER JOIN Lookup.Interval AS i on i.Id = pf.Interval
INNER JOIN Lookup.[PriceIntervalStatus] AS pis on pis.Id = pf.StatusId
INNER JOIN Lookup.ProductResetType AS prt on prt.Id = pp.ResetTypeId
INNER JOIN Lookup.ProductType AS prot on prot.Id = pro.ProductTypeId
INNER JOIN Lookup.PricingModelType AS pmt on pmt.Id = otcc.PricingModelTypeId
INNER JOIN Lookup.ChargeTimingType AS qlctt WITH (nolock) ON pocc.QuantityChargeTimingTypeId = qlctt.Id
INNER JOIN Lookup.ChargeTimingType AS rlctt WITH (nolock) ON pocc.RecurChargeTimingTypeId = rlctt.Id
LEFT OUTER JOIN Lookup.ProrateGranularity AS rlpg WITH (nolock) ON pocc.RecurProrateGranularityId = rlpg.Id
LEFT OUTER JOIN Lookup.ProrateGranularity AS qlpg WITH (nolock) ON pocc.RecurProrateGranularityId = qlpg.Id
LEFT OUTER JOIN Lookup.EarningTimingType AS ett WItH (nolock) ON ett.Id = otcc.EarningTimingTypeId
LEFT OUTER JOIN Lookup.EarningTimingInterval AS eti WITH (nolock) ON eti.Id = otcc.EarningTimingIntervalId
where pe.IsDefault = 1 or pe.IsDefault is null

GO

