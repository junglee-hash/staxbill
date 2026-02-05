
CREATE     PROCEDURE [dbo].[usp_GetFullSubscriptionsForBillingWithHierarchy]
	@customerId bigint,
	@accountId bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT

	SET NOCOUNT ON;


/*   ID TEMP TABLES START  */
CREATE TABLE #Subscriptions
(
SubscriptionId bigint PRIMARY KEY CLUSTERED,
PlanFrequencyUniqueId bigint,
BillingPeriodDefinitionId bigint,
CustomerId bigint
)

CREATE TABLE #SubscriptionProducts
(
SubscriptionProductId bigint PRIMARY KEY CLUSTERED,
SubscriptionId bigint,
PlanProductUniqueId bigint,
ProductId bigint
)

CREATE TABLE #DraftSubscriptionProductCharges
(
DraftSubscriptionProductChargeId bigint PRIMARY KEY CLUSTERED,
SubscriptionProductId bigint
)


-- GET subscriptions by billing period customer
----- This will get all child customer subscriptions that a parent owns
INSERT INTO #Subscriptions (SubscriptionId, PlanFrequencyUniqueId, BillingPeriodDefinitionId, CustomerId)
select 
s.Id,
s.PlanFrequencyUniqueId, 
s.BillingPeriodDefinitionId ,
s.CustomerId
FROM Subscription s 
INNER JOIN BillingPeriodDefinition bpd ON bpd.Id = s.BillingPeriodDefinitionId
WHERE bpd.CustomerId = @customerId
	AND s.StatusId IN (1, 2, 4, 5, 6, 7)
	AND s.IsDeleted = 0


INSERT INTO #DraftSubscriptionProductCharges
SELECT dspc.Id, sp.Id
FROM DraftSubscriptionProductCharge dspc
INNER JOIN SubscriptionProduct sp ON sp.Id = dspc.SubscriptionProductId
INNER JOIN #Subscriptions s ON s.SubscriptionId = sp.SubscriptionId
INNER JOIN DraftCharge dc ON dc.Id = dspc.Id
INNER JOIN DraftInvoice di ON di.Id = dc.DraftInvoiceId
	AND di.DraftInvoiceStatusId IN (1,2) -- Only pending and ready, why do we need cancelled, projected, or deleted?

INSERT INTO #SubscriptionProducts (SubscriptionProductId, SubscriptionId, PlanProductUniqueId, ProductId)
select sp.Id, sp.SubscriptionId, sp.PlanProductUniqueId, sp.ProductId from SubscriptionProduct sp
INNER JOIN #Subscriptions ss ON sp.SubscriptionId = ss.SubscriptionId
WHERE sp.StatusId != 2
  AND (sp.Included = 1
  OR EXISTS (
		SELECT	
			*
		FROM #DraftSubscriptionProductCharges dspc 
		WHERE dspc.SubscriptionProductId = sp.Id
	))
/*   ID TEMP TABLES END  */



/*   PRODUCT ITEM TEMP TABLE START  */

---- add SPI columns here
CREATE TABLE #ProductItem (
    [Id] [bigint]  PRIMARY KEY,
    [CreatedTimestamp] [datetime] NOT NULL,
    [Reference] [nvarchar](255) NOT NULL,
    [Name] [nvarchar](100) NULL,
    [Description] [varchar](255) NULL,
    [ModifiedTimestamp] [datetime] NOT NULL,
    [ProductId] [bigint] NOT NULL,
    [StatusId] [int] NOT NULL,
    [CustomerId] [bigint] NULL,
	[NetsuiteInventoryTimestamp] [datetime] null,
	[NetsuiteInventoryStatusId] [tinyint] not null,
	[SubscriptionProductId] [bigint] NOT NULL,
	[SubscriptionProductActivityJournalId] BIGINT NULL
)
 
DECLARE @Products TABLE (Id BIGINT)
INSERT INTO @Products
SELECT
DISTINCT ProductId
FROM SubscriptionProduct sp 
INNER JOIN #Subscriptions s on s.SubscriptionId = sp.SubscriptionId 

INSERT INTO #ProductItem ([Id]
      ,[CreatedTimestamp]
      ,[Reference]
      ,[Name]
      ,[Description]
      ,[ModifiedTimestamp]
      ,[ProductId]
      ,[StatusId]
      ,[CustomerId]
	  ,[NetsuiteInventoryTimestamp]
	  ,[NetsuiteInventoryStatusId]
	   ,SubscriptionProductId
	  ,[SubscriptionProductActivityJournalId])
SELECT i.[Id]
      ,i.[CreatedTimestamp]
      ,i.[Reference]
      ,i.[Name]
      ,i.[Description]
      ,i.[ModifiedTimestamp]
      ,i.[ProductId]
      ,i.[StatusId]
      ,i.[CustomerId]
	  ,i.[NetsuiteInventoryTimestamp]
	  ,i.[NetsuiteInventoryStatusId]
	, spi.SubscriptionProductId, spi.SubscriptionProductActivityJournalId
	FROM ProductItem i
	INNER JOIN SubscriptionProductItem spi ON i.Id = spi.Id
	INNER JOIN #SubscriptionProducts sp ON sp.SubscriptionProductId = spi.SubscriptionProductId
	WHERE i.StatusId = 1
	AND EXISTS (
		SELECT 1
		FROM @Products p
		WHERE p.Id = i.ProductId
		)

/*   PRODUCT ITEM TEMP TABLE END  */



/*   SPAJ TEMP TABLE START */


CREATE TABLE #SPAJ(
	[Id] [bigint]  PRIMARY KEY,
	[SubscriptionProductId] [bigint] NOT NULL,
	[CreatedTimestamp] [datetime] NOT NULL,
	[DeltaQuantity] [decimal](18, 6) NOT NULL,
	[TotalQuantity] [decimal](18, 6) NOT NULL,
	[Prorated] [bit] NOT NULL,
	[Description] [nvarchar](1000) NULL,
	[HasCompleted] [bit] NOT NULL,
	[EndOfPeriodCharge] [bit] NOT NULL,
	[EndOfPeriodDate] [datetime] NULL,
	[TargetDay] [int] NULL,
	[UseCreatedTimestamp] [bit] NULL
) 

CREATE TABLE #LatestCompletedSPAJ(
	[Id] [bigint]  PRIMARY KEY,
	[SubscriptionProductId] [bigint] NOT NULL
) 

CREATE TABLE #IncompleteSPAJ(
	[Id] [bigint]  PRIMARY KEY,
	[SubscriptionProductId] [bigint] NOT NULL
) 

INSERT INTO #LatestCompletedSPAJ
           (ID,
		   [SubscriptionProductId]
           )
	SELECT MAX(spaj.ID) as ID,
		   spaj.[SubscriptionProductId]
		FROM SubscriptionProductActivityJournal spaj
		INNER JOIN #SubscriptionProducts sp on sp.SubscriptionProductId = spaj.SubscriptionProductId
		WHERE spaj.HasCompleted = 1
		GROUP BY spaj.[SubscriptionProductId]

INSERT INTO #IncompleteSPAJ
           (ID,
		   [SubscriptionProductId]
           )
	SELECT spaj.ID,
		   spaj.[SubscriptionProductId]
		FROM SubscriptionProductActivityJournal spaj
		INNER JOIN #SubscriptionProducts sp on sp.SubscriptionProductId = spaj.SubscriptionProductId
		WHERE spaj.HasCompleted = 0


INSERT INTO #SPAJ
           (ID,
		   [SubscriptionProductId]
           ,[CreatedTimestamp]
           ,[DeltaQuantity]
           ,[TotalQuantity]
           ,[Prorated]
           ,[Description]
           ,[HasCompleted]
           ,[EndOfPeriodCharge]
           ,[EndOfPeriodDate]
           ,[TargetDay]
           ,[UseCreatedTimestamp])
	SELECT  
			spaj2.ID
		   ,spaj2.[SubscriptionProductId]
           ,spaj.[CreatedTimestamp]
           ,spaj.[DeltaQuantity]
           ,spaj.[TotalQuantity]
           ,spaj.[Prorated]
           ,spaj.[Description]
           ,1 --has completed
           ,spaj.[EndOfPeriodCharge]
           ,spaj.[EndOfPeriodDate]
           ,spaj.[TargetDay]
           ,spaj.[UseCreatedTimestamp]
		FROM SubscriptionProductActivityJournal spaj
		INNER JOIN #LatestCompletedSPAJ spaj2 on spaj2.Id = spaj.Id

INSERT INTO #SPAJ
           (ID,
		   [SubscriptionProductId]
           ,[CreatedTimestamp]
           ,[DeltaQuantity]
           ,[TotalQuantity]
           ,[Prorated]
           ,[Description]
           ,[HasCompleted]
           ,[EndOfPeriodCharge]
           ,[EndOfPeriodDate]
           ,[TargetDay]
           ,[UseCreatedTimestamp])
	SELECT  
			spaj2.ID
		   ,spaj2.[SubscriptionProductId]
           ,spaj.[CreatedTimestamp]
           ,spaj.[DeltaQuantity]
           ,spaj.[TotalQuantity]
           ,spaj.[Prorated]
           ,spaj.[Description]
           ,0 --has completed
           ,spaj.[EndOfPeriodCharge]
           ,spaj.[EndOfPeriodDate]
           ,spaj.[TargetDay]
           ,spaj.[UseCreatedTimestamp]
		FROM SubscriptionProductActivityJournal spaj
		INNER JOIN #IncompleteSPAJ spaj2 on spaj2.Id = spaj.Id

/*   SPAJ TEMP TABLE END */





SELECT s.*
      ,[StatusId] as [Status]
      ,[IntervalId] as Interval
  FROM [dbo].[Subscription] s
INNER JOIN #Subscriptions ss ON s.Id = ss.SubscriptionId

SELECT so.* FROM SubscriptionOverride so
INNER JOIN #Subscriptions ss ON so.Id = ss.SubscriptionId

SELECT scc.[Id]
      ,scc.[SubscriptionId]
      ,[CouponCodeId]
      ,scc.[CreatedTimestamp]
      ,scc.[StatusId] as [Status]
      ,[DeletedTimestamp]
  FROM [dbo].[SubscriptionCouponCode] scc
  INNER JOIN #Subscriptions ss ON scc.SubscriptionId = ss.SubscriptionId

  SELECT DISTINCT cc.* FROM CouponCode cc
  INNER JOIN SubscriptionCouponCode scc ON cc.Id = scc.CouponCodeId
  INNER JOIN #Subscriptions ss ON scc.SubscriptionId = ss.SubscriptionId

  SELECT DISTINCT c.* 
	, c.StatusId as [Status]
  FROM Coupon c
  INNER JOIN CouponCode cc ON c.Id = cc.CouponId
  INNER JOIN SubscriptionCouponCode scc ON cc.Id = scc.CouponCodeId
  INNER JOIN #Subscriptions ss ON scc.SubscriptionId = ss.SubscriptionId


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
  INNER JOIN #SubscriptionProducts ss ON ss.SubscriptionProductId = sp.Id
  INNER JOIN PlanProduct pp ON pp.PlanProductUniqueId = sp.PlanProductUniqueId
  ORDER BY pp.SortOrder

  SELECT spo.* FROM SubscriptionProductOverride spo
  INNER JOIN #SubscriptionProducts sp on sp.SubscriptionProductId = spo.Id


SELECT pmo.[Id]
      ,pmo.[CreatedTimestamp]
      ,pmo.[ModifiedTimestamp]
      ,pmo.[PricingModelTypeId] as PricingModelType
  FROM [dbo].[PricingModelOverride] pmo
  INNER JOIN #SubscriptionProducts sp on sp.SubscriptionProductId = pmo.Id

  SELECT pro.* FROM PriceRangeOverride pro
  INNER JOIN PricingModelOverride pmo ON pmo.Id = pro.PricingModelOverrideId
  INNER JOIN #SubscriptionProducts sp on sp.SubscriptionProductId = pmo.Id

SELECT spd.*
      ,[DiscountTypeId] as DiscountType
  FROM [dbo].[SubscriptionProductDiscount] spd
	INNER JOIN #SubscriptionProducts sp on sp.SubscriptionProductId = spd.SubscriptionProductId

SELECT p.*
      ,p.[ProductTypeId] as ProductType
      ,[ProductStatusId] as [Status]
  FROM [dbo].[Product] p
  WHERE p.AccountId = @accountId

SELECT gl.*
      ,gl.[StatusId] as [Status]
  FROM [dbo].[GLCode] gl
  WHERE gl.AccountId = @accountId

  SELECT * FROM SubscriptionProductPriceRange sppr
  INNER JOIN #SubscriptionProducts sp on sp.SubscriptionProductId = sppr.SubscriptionProductId

SELECT spaj.* FROM #SPAJ spaj

SELECT [Id],
    [CreatedTimestamp],
    [Reference],
    [Name],
    [Description] ,
    [ModifiedTimestamp] ,
    [ProductId] ,
    [StatusId] as [Status],
    [CustomerId],
	[NetsuiteInventoryTimestamp],
	[NetsuiteInventoryStatusId]
FROM #ProductItem

SELECT [Id],spi.SubscriptionProductId
	  ,spi.SubscriptionProductActivityJournalId    
FROM #ProductItem spi

  SELECT spd.* FROM SubscriptionProductStartingData spd
  INNER JOIN #SubscriptionProducts sp ON sp.SubscriptionProductId = spd.Id

  SELECT spd.* FROM SubscriptionProductPriceUplift spd
  INNER JOIN #SubscriptionProducts sp ON sp.SubscriptionProductId = spd.SubscriptionProductId

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
  INNER JOIN #Subscriptions ss ON sm.Id = ss.SubscriptionId

  SELECT 
	cc.*
  FROM CouponCode cc
  INNER JOIN ScheduledMigration sm ON cc.Id = sm.CouponCodeId
  INNER JOIN #Subscriptions ss ON sm.Id = ss.SubscriptionId

  SELECT dspc.* FROM DraftSubscriptionProductCharge dspc
  INNER JOIN #DraftSubscriptionProductCharges dd ON dd.DraftSubscriptionProductChargeId = dspc.Id

  SELECT dc.*
	, dc.TransactionTypeId as TransactionType
	, dc.StatusId as [Status]
	, dc.EarningTimingTypeId as EarningTimingType
	, dc.EarningTimingIntervalId as EarningTimingInterval
  FROM #DraftSubscriptionProductCharges dspc
  INNER JOIN DraftCharge dc ON dc.Id = dspc.DraftSubscriptionProductChargeId

  SELECT dct.*
  FROM DraftChargeTier dct
  INNER JOIN #DraftSubscriptionProductCharges dspc on dspc.DraftSubscriptionProductChargeId = dct.DraftChargeId

  SELECT spajdc.*
  FROM SubscriptionProductActivityJournalDraftCharge spajdc
  INNER JOIN #DraftSubscriptionProductCharges dspc on dspc.DraftSubscriptionProductChargeId = spajdc.DraftChargeId

  SELECT spc.* FROM SubscriptionProductCharge spc
    INNER JOIN #SubscriptionProducts sp ON sp.SubscriptionProductId = spc.SubscriptionProductId

	SELECT DISTINCT ppk.* FROM PlanProductKey ppk
  INNER JOIN #SubscriptionProducts sp on sp.PlanProductUniqueId = ppk.Id

  select DISTINCT  pp.*,
  pp.ResetTypeId as ResetType,
  pp.StatusId as [Status]
   FROM PlanProduct pp
	INNER JOIN #SubscriptionProducts sp on sp.PlanProductUniqueId = pp.PlanProductUniqueId

	select spj.*,
		spj.StatusId as [Status]
	FROM SubscriptionStatusJournal spj
	inner join #Subscriptions ss ON ss.SubscriptionId = spj.SubscriptionId

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
  FROM #Subscriptions ss
  LEFT JOIN Migration m ON m.SourceSubscriptionId = ss.SubscriptionId
  LEFT JOIN Migration mm ON mm.DestinationSubscriptionId = ss.SubscriptionId
  WHERE (m.Id IS NOT NULL OR mm.Id IS NOT NULL)
 
-- I know we fetch the customer earlier (in a diff sproc) but because we can have child cusotmers we need to ensure we get them back when the
-- customer is the parent...
SELECT c.*
		, c.AccountStatusId as AccountStatus
		, c.NetsuiteEntityTypeId as NetsuiteEntityType
		, c.QuickBooksLatchTypeId as QuickBooksLatchType
		, c.SalesforceAccountTypeId as SalesforceAccountType
		, c.SalesforceSynchStatusId as SalesforceSynchStatus
		, c.StatusId as [Status]
		, c.TitleId as [Title]
	  FROM [dbo].[Customer] c
	  INNER JOIN #Subscriptions ss ON c.Id = ss.CustomerId

  drop table #SubscriptionProducts
  drop table #Subscriptions
  drop table #ProductItem
  drop table #SPAJ
  drop table #DraftSubscriptionProductCharges
  drop table #IncompleteSPAJ
  drop table #LatestCompletedSPAJ

  END

GO

