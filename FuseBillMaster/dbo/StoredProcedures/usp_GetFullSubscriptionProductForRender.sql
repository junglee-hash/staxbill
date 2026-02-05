
CREATE   PROCEDURE [dbo].[usp_GetFullSubscriptionProductForRender]
	@subscriptionProductId BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

SELECT sp.*
      ,sp.[StatusId] AS [Status]
      ,sp.[EarningTimingTypeId] AS EarningTimingType
      ,sp.[EarningTimingIntervalId] AS EarningTimingInterval
      ,sp.[ProductTypeId] AS ProductTypeId
      ,sp.[ResetTypeId] AS ResetType
      ,sp.[RecurChargeTimingTypeId] AS RecurChargeTimingType
      ,sp.[RecurProrateGranularityId] AS RecurProrateGranularity
      ,sp.[QuantityChargeTimingTypeId] AS QuantityChargeTimingType
      ,sp.[QuantityProrateGranularityId] AS QuantityProrateGranularity
      ,sp.[PricingModelTypeId] AS PricingModelType
      ,sp.[EarningIntervalId] AS EarningInterval
	  ,sp.CustomServiceDateIntervalId AS CustomServiceDateInterval
	  ,sp.CustomServiceDateProjectionId AS CustomServiceDateProjection
FROM [dbo].[SubscriptionProduct] sp
INNER JOIN Subscription s ON s.Id = sp.SubscriptionId
WHERE s.IsDeleted = 0 AND sp.Id = @subscriptionProductId

SELECT s.*
      ,s.[StatusId] AS [Status]
      ,s.[IntervalId] AS Interval    
FROM SubscriptionProduct sp 
INNER JOIN Subscription s ON s.Id = sp.SubscriptionId
WHERE s.IsDeleted = 0 AND sp.Id = @subscriptionProductId

SELECT c.*
	, c.AccountStatusId AS AccountStatus
	, c.NetsuiteEntityTypeId AS NetsuiteEntityType
	, c.QuickBooksLatchTypeId AS QuickBooksLatchType
	, c.SalesforceAccountTypeId AS SalesforceAccountType
	, c.SalesforceSynchStatusId AS SalesforceSynchStatus
	, c.StatusId AS [Status]
	, c.TitleId AS [Title]
FROM SubscriptionProduct sp 
INNER JOIN Subscription s ON s.Id = sp.SubscriptionId
INNER JOIN customer c ON c.Id = s.CustomerId
WHERE c.IsDeleted = 0 AND sp.Id = @subscriptionProductId

SELECT spd.*
      ,[DiscountTypeId] AS DiscountType
FROM [dbo].[SubscriptionProductDiscount] spd
WHERE SubscriptionProductId = @subscriptionProductId

SELECT spo.* 
FROM SubscriptionProductOverride spo
WHERE spo.Id = @subscriptionProductId

SELECT pmo.[Id]
      ,pmo.[CreatedTimestamp]
      ,pmo.[ModifiedTimestamp]
      ,pmo.[PricingModelTypeId] AS PricingModelType
FROM [dbo].[PricingModelOverride] pmo
WHERE pmo.Id = @subscriptionProductId

SELECT pro.* FROM PriceRangeOverride pro
INNER JOIN PricingModelOverride pmo ON pmo.Id = pro.PricingModelOverrideId
WHERE pmo.Id = @subscriptionProductId

SELECT spaj.*
FROM SubscriptionProductActivityJournal spaj
WHERE spaj.SubscriptionProductId = @subscriptionProductId

SELECT spcf.*
FROM SubscriptionProductCustomField spcf
WHERE spcf.SubscriptionProductId = @subscriptionProductId

SELECT * FROM 
( 
	SELECT cf.*, 
			cf.DataTypeId AS [DataType],
			cf.StatusId AS [status]
	FROM CustomField cf
	INNER JOIN SubscriptionProductCustomField spcf ON spcf.CustomFieldId = cf.Id
	WHERE spcf.SubscriptionProductId = @subscriptionProductId 
UNION
	SELECT cf.*, 
			cf.DataTypeId AS [DataType],
			cf.StatusId AS [status]
	FROM CustomField cf
	INNER JOIN PlanProductFrequencyCustomField ppfcf ON ppfcf.CustomFieldId = cf.Id
	INNER JOIN subscriptionproduct sp ON ppfcf.PlanProductUniqueId = sp.PlanProductUniqueId
	WHERE sp.Id = @subscriptionProductId
) q

SELECT sppr.*
FROM dbo.SubscriptionProductPriceRange sppr
WHERE sppr.SubscriptionProductId = @subscriptionProductId

SELECT sppu.*
FROM dbo.SubscriptionProductPriceUplift sppu
WHERE sppu.SubscriptionProductId = @subscriptionProductId

SELECT p.*
	  ,p.[ProductTypeId] AS ProductType
      ,[ProductStatusId] AS [Status]
FROM dbo.product p
INNER JOIN subscriptionProduct sp ON sp.ProductId = p.Id
WHERE sp.Id = @subscriptionProductId

SELECT ppk.* 
FROM PlanProductKey ppk
INNER JOIN subscriptionproduct sp ON sp.PlanProductUniqueId = ppk.Id
WHERE sp.Id = @subscriptionProductId

SELECT pp.*,
		pp.ResetTypeId AS ResetType,
		pp.StatusId AS [Status]
FROM PlanProduct pp
INNER JOIN subscriptionproduct sp ON sp.PlanProductUniqueId = pp.PlanProductUniqueId
WHERE sp.Id = @subscriptionProductId

SELECT DISTINCT ppfcf.* 
FROM PlanProductFrequencyCustomField ppfcf
INNER JOIN subscriptionproduct sp ON ppfcf.PlanProductUniqueId = sp.PlanProductUniqueId
WHERE sp.Id = @subscriptionProductId

SELECT * FROM (
	SELECT gl.*,
			gl.StatusId AS [status]
	FROM dbo.GLCode gl
	INNER JOIN product p ON p.GLCodeId = gl.Id
	INNER JOIN subscriptionProduct sp ON sp.ProductId = p.Id
	WHERE sp.Id = @subscriptionProductId
UNION
	SELECT gl.*,
			gl.StatusId AS [status]
	FROM dbo.GLCode gl
	INNER JOIN planproduct pp ON pp.GLCodeId = gl.Id
	INNER JOIN subscriptionproduct sp ON sp.PlanProductUniqueId = pp.PlanProductUniqueId
	WHERE sp.Id = @subscriptionProductId
) q

END

GO

