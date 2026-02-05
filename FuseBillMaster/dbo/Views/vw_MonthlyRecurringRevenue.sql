CREATE VIEW [dbo].[vw_MonthlyRecurringRevenue]
AS
SELECT
	Amount.SubscriptionProductId, 
	Amount.SubscriptionId, 
	Amount.CustomerId, 
	Amount.AccountId,
	CAST(ISNULL(SUM(Amount.Amount * Amount.UnitsToCharge) * i.MRRMultiplier / Amount.NumberOfIntervals, 0) AS Decimal(10, 2)) AS MRR,
	CASE WHEN CAST(ISNULL((SUM(Amount.Amount * Amount.UnitsToCharge) - ISNULL(TotalDiscount,0)) * i.MRRMultiplier / Amount.NumberOfIntervals, 0) AS Decimal(10, 2)) < 0 THEN 0
	ELSE CAST(ISNULL((SUM(Amount.Amount * Amount.UnitsToCharge) - ISNULL(TotalDiscount,0)) * i.MRRMultiplier / Amount.NumberOfIntervals, 0) AS Decimal(10, 2)) END AS NetMRR
FROM     
	(SELECT 
		SubscriptionProductId, 
		SubscriptionId, 
		CustomerId, 
		Amount, 
		Interval, 
		NumberOfIntervals, 
		CASE WHEN PricingModelTypeId IN (1, 2) THEN 
			CASE WHEN Quantity <= Max AND Quantity > Min THEN Quantity - Min 
				WHEN Quantity >= Max THEN Max - Min 
				ELSE 0 
			END 
			WHEN PricingModelTypeId = 3 THEN 
				CASE WHEN Quantity <= Max AND Quantity > Min THEN 1 
				ELSE 0 
			END 
			WHEN PricingModelTypeId = 4 THEN 
				CASE WHEN Quantity <= Max AND Quantity > Min THEN Quantity 
				ELSE 0 
			END 
		ELSE 0 
		END AS UnitsToCharge, 
		AccountId,
		(SELECT 
			sum(DiscountAmount) as DiscountAmount FROM 
			(SELECT 
				spd.SubscriptionProductId,
				CASE WHEN DiscountTypeId IN (1, 2) THEN 
					CASE WHEN DiscountTypeId = 1 THEN CAST(data.Quantity * data.Amount * spd.amount / 100 AS Decimal(10, 2)) 
					ELSE CAST(spd.Amount AS Decimal(10, 2)) END 
					ELSE 0 END AS DiscountAmount
				FROM dbo.SubscriptionProductDiscount AS spd
                WHERE   (ISNULL(RemainingUsage, 999) > 0) AND (RemainingUsagesUntilStart = 0)) AS DiscountAmount WHERE DiscountAmount.SubscriptionProductId = Data.SubscriptionProductId) AS TotalDiscount
        FROM      
			(SELECT 
				sp.Id AS SubscriptionProductId, 
				sp.Quantity, 
				COALESCE (pro.Min, sppr.Min) AS Min, 
				CASE WHEN COALESCE (pro.Max, sppr.Max) IS NULL THEN 999999999999999999.999999 ELSE COALESCE (pro.Max, sppr.Max) END AS Max, 
				COALESCE (pro.Price, sppr.Amount) AS Amount, 
				s.IntervalId as Interval, 
				s.NumberOfIntervals, 
				c.Id AS CustomerId, 
				sp.SubscriptionId, 
				c.AccountId, 
				sp.PricingModelTypeId	
                FROM      dbo.SubscriptionProduct AS sp INNER JOIN
						dbo.SubscriptionProductPriceRange sppr ON sp.Id = sppr.SubscriptionProductId INNER JOIN
                                dbo.Subscription AS s ON sp.SubscriptionId = s.Id INNER JOIN
                                dbo.Customer AS c ON s.CustomerId = c.Id INNER JOIN
                                dbo.CustomerStatusJournal AS csj ON c.Id = csj.CustomerId AND csj.IsActive = 1 LEFT JOIN
                                dbo.PricingModelOverride AS pmo ON sp.Id = pmo.Id LEFT OUTER JOIN
                                dbo.PriceRangeOverride AS pro ON pmo.Id = pro.PricingModelOverrideId
                WHERE (sp.StatusId = 1) AND (sp.IsRecurring = 1) AND (sp.ResetTypeId = 1) AND (sp.Included = 1) AND (sp.StartDate IS NULL) AND (s.StatusId = 2) AND (csj.StatusId = 2) AND 
                                (s.CancellationTimestamp IS NULL) OR
                                (sp.Included = 1) AND (sp.StartDate < GETUTCDATE()) AND (s.StatusId = 2) AND (s.CancellationTimestamp IS NULL)) AS Data) AS Amount INNER JOIN
                  Lookup.Interval AS i ON Amount.Interval = i.Id
GROUP BY i.MRRMultiplier, Amount.NumberOfIntervals, Amount.SubscriptionProductId, Amount.CustomerId, Amount.SubscriptionId, Amount.AccountId, Amount.TotalDiscount

GO

