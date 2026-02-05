
CREATE PROCEDURE [dbo].[usp_GetFullSubscriptionProducts]
	@subscriptionProductIds nvarchar(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

declare @subscriptionProducts table
(
SubscriptionProductId bigint
)

INSERT INTO @subscriptionProducts (SubscriptionProductId)
select Data from dbo.Split (@subscriptionProductIds,'|') d 
INNER JOIN subscriptionProduct sp on sp.Id = d.Data
INNER JOIN subscription s on s.Id = sp.SubscriptionId
where s.IsDeleted = 0

SELECT s.*
      ,s.[StatusId] as [Status]
      ,s.[IntervalId] as Interval
      
  FROM [dbo].[Subscription] s
  INNER JOIN SubscriptionProduct sp ON s.Id = sp.SubscriptionId
INNER JOIN @subscriptionProducts sps ON sp.Id = sps.SubscriptionProductId
WHERE s.IsDeleted = 0


SELECT cf.*
      ,[DataTypeId] as [DataType]
      ,cf.[StatusId] as [Status]
  FROM [dbo].[CustomField] cf
  INNER JOIN SubscriptionProductCustomField spcf ON cf.Id = spcf.CustomFieldId
  INNER JOIN SubscriptionProduct sp ON sp.Id = spcf.SubscriptionProductId
  INNER JOIN @subscriptionProducts sps ON sp.Id = sps.SubscriptionProductId
UNION
SELECT cf.*
      ,[DataTypeId] as [DataType]
      ,cf.[StatusId] as [Status]
  FROM [dbo].[CustomField] cf
  INNER JOIN PlanProductFrequencyCustomField ppfcf ON cf.Id = ppfcf.CustomFieldId
  INNER JOIN SubscriptionProduct sp ON ppfcf.PlanProductUniqueId = sp.PlanProductUniqueId
  INNER JOIN @subscriptionProducts sps ON sp.Id = sps.SubscriptionProductId
  INNER JOIN Subscription s ON s.Id = sp.SubscriptionId AND ppfcf.PlanFrequencyUniqueId = s.PlanFrequencyUniqueId


SELECT sp.*
      ,[StatusId] as [Status]
      ,[EarningTimingTypeId] as EarningTimingType
      ,[EarningTimingIntervalId] as EarningTimingInterval
      ,[ProductTypeId] as ProductTypeId
      ,[ResetTypeId] as ResetType
      ,[RecurChargeTimingTypeId] as RecurChargeTimingType
      ,[RecurProrateGranularityId] as RecurProrateGranularity
      ,[QuantityChargeTimingTypeId] as QuantityChargeTimingType
      ,[QuantityProrateGranularityId] as QuantityProrateGranularity
      ,[PricingModelTypeId] as PricingModelType
      ,[EarningIntervalId] as EarningInterval
	  ,CustomServiceDateIntervalId as CustomServiceDateInterval
	  ,CustomServiceDateProjectionId as CustomServiceDateProjection
  FROM [dbo].[SubscriptionProduct] sp
INNER JOIN @subscriptionProducts sps ON sp.Id = sps.SubscriptionProductId

  SELECT spo.* FROM SubscriptionProductOverride spo
  INNER JOIN SubscriptionProduct sp ON sp.Id = spo.Id
  INNER JOIN @subscriptionProducts sps ON sp.Id = sps.SubscriptionProductId

  SELECT ppk.* FROM PlanProductKey ppk
  INNER JOIN SubscriptionProduct sp ON ppk.Id = sp.PlanProductUniqueId
  INNER JOIN @subscriptionProducts sps ON sp.Id = sps.SubscriptionProductId

  SELECT ppfcf.* FROM PlanProductFrequencyCustomField ppfcf
  INNER JOIN SubscriptionProduct sp ON ppfcf.PlanProductUniqueId = sp.PlanProductUniqueId
  INNER JOIN @subscriptionProducts sps ON sp.Id = sps.SubscriptionProductId
  INNER JOIN Subscription s ON s.Id = sp.SubscriptionId AND ppfcf.PlanFrequencyUniqueId = s.PlanFrequencyUniqueId

  SELECT spcf.* FROM SubscriptionProductCustomField spcf
  INNER JOIN SubscriptionProduct sp ON sp.Id = spcf.SubscriptionProductId
  INNER JOIN @subscriptionProducts sps ON sp.Id = sps.SubscriptionProductId

SELECT pmo.*
      ,pmo.[PricingModelTypeId] as PricingModelType
  FROM [dbo].[PricingModelOverride] pmo
INNER JOIN SubscriptionProduct sp ON sp.Id = pmo.Id
  INNER JOIN @subscriptionProducts sps ON sp.Id = sps.SubscriptionProductId

  SELECT pro.* FROM PriceRangeOverride pro
  INNER JOIN PricingModelOverride pmo ON pmo.Id = pro.PricingModelOverrideId
  INNER JOIN SubscriptionProduct sp ON sp.Id = pmo.Id
  INNER JOIN @subscriptionProducts sps ON sp.Id = sps.SubscriptionProductId

SELECT spd.*
      ,[DiscountTypeId] as DiscountType
  FROM [dbo].[SubscriptionProductDiscount] spd
  INNER JOIN SubscriptionProduct sp ON sp.Id = spd.SubscriptionProductId
  INNER JOIN @subscriptionProducts sps ON sp.Id = sps.SubscriptionProductId

SELECT p.*
      ,p.[ProductTypeId] as ProductType
      ,[ProductStatusId] as [Status]
  FROM [dbo].[Product] p
  INNER JOIN SubscriptionProduct sp ON p.Id = sp.ProductId
  INNER JOIN @subscriptionProducts sps ON sp.Id = sps.SubscriptionProductId

  SELECT sppr.* FROM SubscriptionProductPriceRange sppr
  INNER JOIN SubscriptionProduct sp ON sp.Id = sppr.SubscriptionProductId
  INNER JOIN @subscriptionProducts sps ON sp.Id = sps.SubscriptionProductId

SELECT i.*
      ,i.[StatusId] as [Status]
  FROM [dbo].[ProductItem] i
  INNER JOIN SubscriptionProductItem spi ON i.Id = spi.Id
  INNER JOIN SubscriptionProduct sp ON sp.Id = spi.SubscriptionProductId
  INNER JOIN @subscriptionProducts sps ON sp.Id = sps.SubscriptionProductId

  SELECT
	spi.Id,
	spi.SubscriptionProductId,
	spi.SubscriptionProductActivityJournalId
  FROM SubscriptionProductItem spi
  INNER JOIN SubscriptionProduct sp ON sp.Id = spi.SubscriptionProductId
  INNER JOIN @subscriptionProducts sps ON sp.Id = sps.SubscriptionProductId

  SELECT * FROM SubscriptionProductStartingData spd
  INNER JOIN @subscriptionProducts sps ON spd.Id = sps.SubscriptionProductId

  SELECT * FROM SubscriptionProductPriceUplift spd
  INNER JOIN @subscriptionProducts sps ON spd.SubscriptionProductId = sps.SubscriptionProductId

  END

GO

