
CREATE   PROCEDURE [dbo].[usp_GetFullSubscriptionsWithIncludedProductsForRender]
	@subscriptionIds AS dbo.IDList READONLY,
	@accountId bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/*   ID TEMP TABLES START  */
declare @subscriptions table
(
[SortOrder] int,
SubscriptionId bigint,
PlanFrequencyUniqueId bigint,
BillingPeriodDefinitionId bigint
)

declare @customers table
(
CustomerId bigint
)

declare @subscriptionproducts table
(
SubscriptionProductId bigint,
SubscriptionId bigint,
PlanProductUniqueId bigint,
ProductId bigint
)

--Assumption is that an unknown account is coming from an account agnostic Fusebill process, so we don't want to filter
IF @accountId = 0 
BEGIN
	SET @accountId = NULL
END

;WITH DistinctSubscriptions AS (
	SELECT DISTINCT
		Id
	FROM @subscriptionIds
)
INSERT INTO @subscriptions ([SortOrder], SubscriptionId, PlanFrequencyUniqueId, BillingPeriodDefinitionId)
select
ROW_NUMBER() OVER (ORDER BY (SELECT 100)) AS [SortOrder],
ids.Id, 
s.PlanFrequencyUniqueId, 
s.BillingPeriodDefinitionId 
from DistinctSubscriptions ids
INNER JOIN Subscription s ON s.Id = ids.Id
WHERE s.AccountId = ISNULL(@accountId,s.AccountId)
And s.IsDeleted = 0

INSERT INTO @customers (CustomerId)
select CustomerId from Subscription s
INNER JOIN @subscriptions ss ON s.Id = ss.SubscriptionId

INSERT INTO @subscriptionproducts (SubscriptionProductId, SubscriptionId, PlanProductUniqueId, ProductId)
select sp.Id, sp.SubscriptionId, sp.PlanProductUniqueId, sp.ProductId from SubscriptionProduct sp
INNER JOIN @subscriptions ss ON sp.SubscriptionId = ss.SubscriptionId
WHERE sp.Included = 1

/*   ID TEMP TABLES END  */

SELECT s.*
      ,[StatusId] as [Status]
      ,[IntervalId] as Interval
  FROM [dbo].[Subscription] s
INNER JOIN @subscriptions ss ON s.Id = ss.SubscriptionId
ORDER BY ss.[SortOrder]

SELECT so.* FROM SubscriptionOverride so
INNER JOIN @subscriptions ss ON so.Id = ss.SubscriptionId

SELECT scc.[Id]
      ,scc.[SubscriptionId]
      ,[CouponCodeId]
      ,scc.[CreatedTimestamp]
      ,scc.[StatusId] as [Status]
      ,[DeletedTimestamp]
  FROM [dbo].[SubscriptionCouponCode] scc
  INNER JOIN @subscriptions ss ON scc.SubscriptionId = ss.SubscriptionId

  SELECT DISTINCT cc.* FROM CouponCode cc
  INNER JOIN SubscriptionCouponCode scc ON cc.Id = scc.CouponCodeId
  INNER JOIN @subscriptions ss ON scc.SubscriptionId = ss.SubscriptionId

  SELECT DISTINCT c.* 
	, c.StatusId as [Status]
  FROM Coupon c
  INNER JOIN CouponCode cc ON c.Id = cc.CouponId
  INNER JOIN SubscriptionCouponCode scc ON cc.Id = scc.CouponCodeId
  INNER JOIN @subscriptions ss ON scc.SubscriptionId = ss.SubscriptionId

  SELECT scf.* FROM SubscriptionCustomField scf
  INNER JOIN @subscriptions ss ON scf.SubscriptionId = ss.SubscriptionId

SELECT DISTINCT cf.[Id]
      ,[AccountId]
      ,[FriendlyName]
      ,[Key]
      ,[DataTypeId] as [DataType]
      ,[StatusId] as [Status]
      ,cf.[CreatedTimestamp]
      ,cf.[ModifiedTimestamp]
  FROM [dbo].[CustomField] cf
  INNER JOIN SubscriptionCustomField scf ON cf.Id = scf.CustomFieldId
  INNER JOIN @subscriptions ss ON scf.SubscriptionId = ss.SubscriptionId
UNION
SELECT DISTINCT cf.[Id]
      ,[AccountId]
      ,[FriendlyName]
      ,[Key]
      ,[DataTypeId] as [DataType]
      ,cf.[StatusId] as [Status]
      ,cf.[CreatedTimestamp]
      ,cf.[ModifiedTimestamp]
  FROM [dbo].[CustomField] cf
  INNER JOIN PlanFrequencyCustomField pfcf ON cf.Id = pfcf.CustomFieldId
  INNER JOIN @subscriptions ss ON pfcf.PlanFrequencyUniqueId = ss.PlanFrequencyUniqueId
UNION
SELECT DISTINCT cf.[Id]
      ,[AccountId]
      ,[FriendlyName]
      ,[Key]
      ,[DataTypeId] as [DataType]
      ,cf.[StatusId] as [Status]
      ,cf.[CreatedTimestamp]
      ,cf.[ModifiedTimestamp]
  FROM [dbo].[CustomField] cf
  INNER JOIN SubscriptionProductCustomField spcf ON cf.Id = spcf.CustomFieldId
  INNER JOIN @subscriptionproducts sp on sp.SubscriptionProductId = spcf.SubscriptionProductId
UNION
SELECT DISTINCT cf.[Id]
      ,[AccountId]
      ,[FriendlyName]
      ,[Key]
      ,[DataTypeId] as [DataType]
      ,cf.[StatusId] as [Status]
      ,cf.[CreatedTimestamp]
      ,cf.[ModifiedTimestamp]
  FROM [dbo].[CustomField] cf
  INNER JOIN PlanProductFrequencyCustomField ppfcf ON cf.Id = ppfcf.CustomFieldId
  INNER JOIN @subscriptionproducts sp on ppfcf.PlanProductUniqueId = sp.PlanProductUniqueId 
  INNER JOIN @subscriptions s ON s.SubscriptionId = sp.SubscriptionId AND ppfcf.PlanFrequencyUniqueId = s.PlanFrequencyUniqueId


  SELECT DISTINCT pfk.* FROM PlanFrequencyKey pfk
  INNER JOIN @subscriptions ss ON pfk.Id = ss.PlanFrequencyUniqueId

  SELECT DISTINCT pfcf.* FROM PlanFrequencyCustomField pfcf
   INNER JOIN @subscriptions ss ON pfcf.PlanFrequencyUniqueId = ss.PlanFrequencyUniqueId

SELECT bpd.*
      ,bpd.[IntervalId] as Interval
      ,[BillingPeriodTypeId] as BillingPeriodType
  FROM [dbo].[BillingPeriodDefinition] bpd
  INNER JOIN @subscriptions ss ON ss.BillingPeriodDefinitionId = bpd.Id

SELECT bp.*
      ,bp.[PeriodStatusId] as PeriodStatus
  FROM [dbo].[BillingPeriod] bp
  INNER JOIN BillingPeriodDefinition bpd ON bpd.Id = bp.BillingPeriodDefinitionId
  INNER JOIN @subscriptions ss ON ss.BillingPeriodDefinitionId = bpd.Id
  WHERE bp.PeriodStatusId = 1

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
  INNER JOIN @subscriptions ss ON sp.SubscriptionId = ss.SubscriptionId
  INNER JOIN PlanProduct pp ON pp.PlanProductUniqueId = sp.PlanProductUniqueId
  WHERE sp.StatusId != 2 AND sp.Included = 1
  ORDER BY pp.SortOrder

  SELECT spo.* FROM SubscriptionProductOverride spo
  INNER JOIN @subscriptionproducts sp on sp.SubscriptionProductId = spo.Id

  SELECT DISTINCT ppk.* FROM PlanProductKey ppk
  INNER JOIN @subscriptionproducts sp on sp.PlanProductUniqueId = ppk.Id

  select DISTINCT  pp.*,
  pp.ResetTypeId as ResetType,
  pp.StatusId as [Status]
   FROM PlanProduct pp
	INNER JOIN @subscriptionproducts sp on sp.PlanProductUniqueId = pp.PlanProductUniqueId

--saw duplicate results for this, might cause entity framework performance issue?
  SELECT DISTINCT ppfcf.* FROM PlanProductFrequencyCustomField ppfcf
  INNER JOIN @subscriptionproducts sp on ppfcf.PlanProductUniqueId = sp.PlanProductUniqueId
  INNER JOIN @subscriptions ss on ss.PlanFrequencyUniqueId = ppfcf.PlanFrequencyUniqueId

  SELECT spcf.* FROM SubscriptionProductCustomField spcf
  INNER JOIN @subscriptionproducts sp on sp.SubscriptionProductId = spcf.SubscriptionProductId

SELECT pmo.[Id]
      ,pmo.[CreatedTimestamp]
      ,pmo.[ModifiedTimestamp]
      ,pmo.[PricingModelTypeId] as PricingModelType
  FROM [dbo].[PricingModelOverride] pmo
  INNER JOIN @subscriptionproducts sp on sp.SubscriptionProductId = pmo.Id

  SELECT pro.* FROM PriceRangeOverride pro
  INNER JOIN PricingModelOverride pmo ON pmo.Id = pro.PricingModelOverrideId
  INNER JOIN @subscriptionproducts sp on sp.SubscriptionProductId = pmo.Id

SELECT spd.*
      ,[DiscountTypeId] as DiscountType
  FROM [dbo].[SubscriptionProductDiscount] spd
	INNER JOIN @subscriptionproducts sp on sp.SubscriptionProductId = spd.SubscriptionProductId

SELECT DISTINCT p.*
      ,p.[ProductTypeId] as ProductType
      ,[ProductStatusId] as [Status]
  FROM [dbo].[Product] p
  INNER JOIN @subscriptionproducts sp on sp.ProductId = p.Id

SELECT DISTINCT gl.*
      ,gl.[StatusId] as [Status]
  FROM [dbo].[GLCode] gl
  WHERE gl.AccountId = @accountId

  SELECT * FROM SubscriptionProductPriceRange sppr
  INNER JOIN @subscriptionproducts sp on sp.SubscriptionProductId = sppr.SubscriptionProductId

  SELECT * FROM SubscriptionProductPriceUplift spd
  INNER JOIN @subscriptionproducts sp ON sp.SubscriptionProductId = spd.SubscriptionProductId

  SELECT c.*
		, c.AccountStatusId as AccountStatus
		, c.NetsuiteEntityTypeId as NetsuiteEntityType
		, c.QuickBooksLatchTypeId as QuickBooksLatchType
		, c.SalesforceAccountTypeId as SalesforceAccountType
		, c.SalesforceSynchStatusId as SalesforceSynchStatus
		, c.StatusId as [Status]
		, c.TitleId as [Title]
	  FROM [dbo].[Customer] c
	  INNER JOIN @customers cc ON c.Id = cc.CustomerId

SELECT 
	sm.*
	, EarningOptionId as EarningOption
	, NameOverrideOptionId as NameOverrideOption
	, DescriptionOverrideOptionId as DescriptionOverrideOption
	, ReferenceOptionId as ReferenceOption
	, ExpiryOptionId as ExpiryOption
	, ContractStartOptionId as ContractStartOption
	, ContractEndOptionId as ContractEndOption
	, MigrationTimingOptionId as MigrationTimingOption
	, CustomFieldsOptionId
  FROM ScheduledMigration sm
  INNER JOIN @subscriptions ss ON sm.Id = ss.SubscriptionId

SELECT
	 COALESCE(m.[Id], mm.[Id]) as Id
    ,COALESCE(m.[FusebillId], mm.[FusebillId]) as [FusebillId]
    ,COALESCE(m.[RelationshipId], mm.[RelationshipId]) as [RelationshipId]
    ,COALESCE(m.[SourcePlanFrequencyId], mm.[SourcePlanFrequencyId]) as [SourcePlanFrequencyId]
    ,COALESCE(m.[DestinationPlanFrequencyId], mm.[DestinationPlanFrequencyId]) as [DestinationPlanFrequencyId]
    ,COALESCE(m.[SourceSubscriptionId], mm.[SourceSubscriptionId]) as [SourceSubscriptionId]
    ,COALESCE(m.[DestinationSubscriptionId], mm.[DestinationSubscriptionId]) as [DestinationSubscriptionId]
    ,COALESCE(m.[EffectiveTimestamp],mm.[EffectiveTimestamp]) as [EffectiveTimestamp]
    ,COALESCE(m.[SourceCurrentMRR], mm.[SourceCurrentMRR]) as [SourceCurrentMRR]
    ,COALESCE(m.[SourceCurrentNetMRR], mm.[SourceCurrentNetMRR]) as [SourceCurrentNetMRR]
    ,COALESCE(m.[SourceCommittedMRR], mm.[SourceCommittedMRR]) as [SourceCommittedMRR]
    ,COALESCE(m.[SourceCommittedNetMRR], mm.[SourceCommittedNetMRR]) as [SourceCommittedNetMRR]
    ,COALESCE(m.[DestinationCurrentMRR], mm.[DestinationCurrentMRR]) as [DestinationCurrentMRR]
    ,COALESCE(m.[DestinationCurrentNetMRR], mm.[DestinationCurrentNetMRR]) as [DestinationCurrentNetMRR]
    ,COALESCE(m.[DestinationCommittedMRR], mm.[DestinationCommittedMRR]) as [DestinationCommittedMRR]
    ,COALESCE(m.[DestinationCommittedNetMRR], mm.[DestinationCommittedNetMRR]) as [DestinationCommittedNetMRR]
	,COALESCE(m.RelationshipMigrationTypeId, mm.RelationshipMigrationTypeId) as RelationshipMigrationType
	,COALESCE(m.MigrationTimingOptionId, mm.MigrationTimingOptionId) as MigrationTimingOption
	,COALESCE(m.EarningOptionId, mm.EarningOptionId) as EarningOption
	,COALESCE(m.CouponCodeId, mm.CouponCodeId) as CouponCodeId
  FROM @subscriptions ss
  LEFT JOIN Migration m ON m.SourceSubscriptionId = ss.SubscriptionId
  LEFT JOIN Migration mm ON mm.DestinationSubscriptionId = ss.SubscriptionId
  WHERE (m.Id IS NOT NULL OR mm.Id IS NOT NULL)

  SELECT 
	cc.*
  FROM CouponCode cc
  INNER JOIN ScheduledMigration sm ON cc.Id = sm.CouponCodeId
  INNER JOIN @subscriptions ss ON sm.Id = ss.SubscriptionId
  
  SELECT ss.SubscriptionId, 1 as HasPlanFamilyPlan FROM PlanFamilyPlan pfp
  INNER JOIN Subscription s ON s.PlanId = pfp.PlanId
  INNER JOIN @subscriptions ss ON s.Id = ss.SubscriptionId
  
    END

GO

