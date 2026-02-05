

CREATE      PROCEDURE [dbo].[usp_GetSubscriptionForBulkPriceChange]
	@subscriptionId BIGINT,
	@accountId BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


SELECT s.*
      ,[StatusId] as [Status]
      ,[IntervalId] as Interval
  INTO #subscriptionTemp
  FROM [dbo].[Subscription] s
  WHERE s.Id = @subscriptionId
  AND s.IsDeleted = 0 --shouldn't be possible to call this for a deleted sub, but adding just in case we reuse this sproc elsewhere in future
  AND s.AccountId = @accountId --shouldn't be possible to call this for an ID that doesn't belong to the account. This is here for safety too

SELECT * from #subscriptionTemp
SET @subscriptionId = (select Id from #subscriptionTemp) --prevents future result sets form containing anything if account ID didn't match sub account ID


SELECT scc.[Id]
      ,scc.[SubscriptionId]
      ,[CouponCodeId]
      ,scc.[CreatedTimestamp]
      ,scc.[StatusId] as [Status]
      ,[DeletedTimestamp]
  FROM [dbo].[SubscriptionCouponCode] scc
  WHERE scc.SubscriptionId = @subscriptionId

  SELECT DISTINCT cc.* FROM CouponCode cc
  INNER JOIN SubscriptionCouponCode scc ON cc.Id = scc.CouponCodeId
  WHERE scc.SubscriptionId = @subscriptionId

  SELECT DISTINCT c.* 
	, c.StatusId as [Status]
  FROM Coupon c
  INNER JOIN CouponCode cc ON c.Id = cc.CouponId
  INNER JOIN SubscriptionCouponCode scc ON cc.Id = scc.CouponCodeId
  WHERE scc.SubscriptionId = @subscriptionId

SELECT bpd.*
      ,bpd.[IntervalId] as Interval
      ,[BillingPeriodTypeId] as BillingPeriodType
  FROM [dbo].[BillingPeriodDefinition] bpd
  INNER JOIN Subscription s on s.BillingPeriodDefinitionId = bpd.Id
  WHERE s.Id = @subscriptionId

SELECT sp.Id INTO #subscriptionProductIds
FROM subscriptionProduct sp 
where sp.SubscriptionId = @subscriptionId

SELECT DISTINCT spc.BillingPeriodId INTO #BillingPeriodsFromPastCharges
FROM SubscriptionProductCharge spc
INNER JOIN #subscriptionProductIds sp ON sp.Id = spc.SubscriptionProductId

SELECT bp.*
      ,bp.[PeriodStatusId] as PeriodStatus
  FROM [dbo].[BillingPeriod] bp
  INNER JOIN BillingPeriodDefinition bpd ON bpd.Id = bp.BillingPeriodDefinitionId
  INNER JOIN Subscription s on s.BillingPeriodDefinitionId = bpd.Id
  WHERE s.Id = @subscriptionId
  AND bp.PeriodStatusId = 1 --open
union
	SELECT bp.*
		,bp.[PeriodStatusId] as PeriodStatus
	FROM [dbo].[BillingPeriod] bp
	INNER JOIN #BillingPeriodsFromPastCharges bpfpc on bpfpc.BillingPeriodId = bp.Id



SELECT sp.*
      ,sp.[StatusId] as [Status]
      ,[EarningTimingTypeId] as EarningTimingType
      ,[EarningTimingIntervalId] as EarningTimingInterval
      ,[ProductTypeId] as ProductTypeId
      ,sp.[ResetTypeId] as ResetType
      ,[RecurChargeTimingTypeId] as RecurChargeTimingType
      ,[RecurProrateGranularityId] as RecurProrateGranularity
      ,[QuantityChargeTimingTypeId] as QuantityChargeTimingType
      ,[QuantityProrateGranularityId] as QuantityProrateGranularity
      ,[PricingModelTypeId] as PricingModelType
      ,[EarningIntervalId] as EarningInterval
	  ,CustomServiceDateIntervalId as CustomServiceDateInterval
	  ,CustomServiceDateProjectionId as CustomServiceDateProjection
  FROM [dbo].[SubscriptionProduct] sp 
  WHERE sp.StatusId != 2 
  AND sp.SubscriptionId = @subscriptionId

SELECT pmo.[Id]
      ,pmo.[CreatedTimestamp]
      ,pmo.[ModifiedTimestamp]
      ,pmo.[PricingModelTypeId] as PricingModelType
  FROM [dbo].[PricingModelOverride] pmo
  INNER JOIN SubscriptionProduct sp on sp.Id = pmo.Id
  WHERE sp.StatusId != 2 
  AND sp.SubscriptionId = @subscriptionId

  SELECT pro.* FROM PriceRangeOverride pro
  INNER JOIN PricingModelOverride pmo ON pmo.Id = pro.PricingModelOverrideId
  INNER JOIN subscriptionproduct sp on sp.Id = pmo.Id
  WHERE sp.SubscriptionId = @subscriptionId

SELECT spd.*
      ,[DiscountTypeId] as DiscountType
  FROM [dbo].[SubscriptionProductDiscount] spd
	INNER JOIN subscriptionproduct sp on sp.Id = spd.SubscriptionProductId
	WHERE sp.SubscriptionId = @subscriptionId

  SELECT * FROM SubscriptionProductPriceRange sppr
  INNER JOIN subscriptionproduct sp on sp.Id = sppr.SubscriptionProductId
	WHERE sp.SubscriptionId = @subscriptionId

  DROP TABLE #subscriptionTemp
  DROP TABLE #subscriptionProductIds
  DROP TABLE #BillingPeriodsFromPastCharges

  END

GO

