
CREATE PROCEDURE [dbo].[usp_GetDraftInvoicesForPatching]
	@customerId bigint,
	@includeProjected bit
AS
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

--Populate the draft invoices
CREATE TABLE #DraftInvoices (
 [Id] Bigint NOT NULL PRIMARY KEY CLUSTERED
)
INSERT INTO #DraftInvoices
(
d.id
)
SELECT
	d.id
FROM [dbo].[DraftInvoice] d
where d.CustomerId = @customerId and d.DraftInvoiceStatusId in ( 1,2, case @includeProjected when 1 Then 5 End)

--Populate the draft charges
CREATE TABLE #DraftCharges (
 [Id] Bigint NOT NULL PRIMARY KEY CLUSTERED
)
INSERT INTO #DraftCharges
(
dc.id
)
SELECT
	dc.id
FROM [dbo].[DraftCharge] dc
INNER JOIN #DraftInvoices di on dc.DraftInvoiceId = di.Id

--Fetch the data
SELECT d.*
	, DraftInvoiceStatusId as DraftInvoiceStatus
FROM [dbo].[DraftInvoice] d
INNER JOIN #DraftInvoices di on d.id = di.Id

SELECT dt.Id
	, dt.TaxRuleId
	, dt.DraftInvoiceId
	, dt.DraftChargeId
	, dt.Amount
	, dt.CurrencyId
FROM [dbo].[DraftTax] dt
INNER JOIN #DraftInvoices di on dt.DraftInvoiceId = di.Id

SELECT ds.*
FROM [dbo].[DraftPaymentSchedule] ds
INNER JOIN #DraftInvoices di on ds.DraftInvoiceId = di.Id

SELECT dc.Id
	, dc.CreatedTimestamp
	, dc.ModifiedTimestamp
	, dc.Quantity
	, dc.UnitPrice
	, dc.Amount
	, dc.DraftInvoiceId
	, dc.Name
	, dc.[Description]
	, dc.TransactionTypeId as TransactionType
	, dc.CurrencyId
	, dc.EffectiveTimestamp
	, dc.ProratedUnitPrice
	, dc.RangeQuantity
	, dc.TaxableAmount
	, dc.StatusId as [Status]
	, dc.SortOrder
	, dc.CustomerId
	, dc.EarningTimingTypeId as EarningTimingType
	, dc.EarningTimingIntervalId as EarningTimingInterval
	, dc.ProductId
	, dc.DigitalRiverCheckoutId
FROM [dbo].[DraftCharge] dc
INNER JOIN #DraftCharges di on dc.id = di.Id

SELECT 
	dd.DiscountTypeId as DiscountType    
	 , dd.TransactionTypeId as TransactionType 
	 ,*
FROM [dbo].[DraftDiscount] dd
INNER JOIN #DraftCharges dc ON dc.Id = dd.DraftChargeId

SELECT p.*
	, p.StatusId as [Status]
	, p.PricingModelTypeId as PricingModelType
	, p.EarningTimingTypeId as EarningTimingType
	, p.EarningTimingIntervalId as EarningTimingInterval
FROM [dbo].[DraftPurchaseCharge] dpc
INNER JOIN [dbo].[Purchase] p ON p.Id = dpc.PurchaseId
INNER JOIN #DraftCharges dc ON dc.Id = dpc.Id

SELECT dspc.*
FROM [dbo].[DraftSubscriptionProductCharge] dspc
INNER JOIN #DraftCharges dc ON dc.Id = dspc.Id

SELECT dcpi.*
FROM [dbo].[DraftChargeProductItem] dcpi
INNER JOIN #DraftCharges dc ON dc.Id = dcpi.DraftChargeId

SELECT i.*
      ,i.[StatusId] as [Status]
 FROM [dbo].[ProductItem] i
INNER JOIN [dbo].[DraftChargeProductItem] dcpi ON dcpi.ProductItemId = i.Id
INNER JOIN #DraftCharges dc ON dc.Id = dcpi.DraftChargeId

SELECT dpc.*
FROM [dbo].[DraftPurchaseCharge] dpc
INNER JOIN #DraftCharges dc ON dc.Id = dpc.Id

SELECT p.*
      ,p.[ProductTypeId] as ProductType
      ,p.[ProductStatusId] as Status
FROM [dbo].[Product] p
INNER JOIN Purchase pu ON p.Id = pu.ProductId
INNER JOIN [dbo].[DraftPurchaseCharge] dpc ON pu.Id = dpc.PurchaseId
INNER JOIN #DraftCharges dc ON dc.Id = dpc.Id
UNION ALL
SELECT p.*
      ,p.[ProductTypeId] as ProductType
      ,p.[ProductStatusId] as Status
FROM [dbo].[Product] p
INNER JOIN SubscriptionProduct sp ON p.Id = sp.ProductId
INNER JOIN [dbo].[DraftSubscriptionProductCharge] dpc ON sp.Id = dpc.SubscriptionProductId
INNER JOIN #DraftCharges dc ON dc.Id = dpc.Id

SELECT dpc.*
FROM [dbo].[DraftChargeTier] dpc
INNER JOIN #DraftCharges dc ON dc.Id = dpc.DraftChargeId

SELECT DISTINCT s.*
      ,s.[StatusId] as [Status]
      ,s.[IntervalId] as Interval
FROM [dbo].[DraftSubscriptionProductCharge] dspc
INNER JOIN #DraftCharges dc ON dc.Id = dspc.Id
INNER JOIN [dbo].SubscriptionProduct sp on sp.Id = dspc.SubscriptionProductId
INNER JOIN [dbo].[Subscription] s on s.Id = sp.SubscriptionId

SELECT sp.*
      ,sp.[StatusId] as [Status]
      ,sp.[EarningTimingTypeId] as EarningTimingType
      ,sp.[EarningTimingIntervalId] as EarningTimingInterval
      ,sp.[ProductTypeId] as ProductTypeId
      ,sp.[ResetTypeId] as ResetType
      ,sp.[RecurChargeTimingTypeId] as RecurChargeTimingType
      ,sp.[RecurProrateGranularityId] as RecurProrateGranularity
      ,sp.[QuantityChargeTimingTypeId] as QuantityChargeTimingType
      ,sp.[QuantityProrateGranularityId] as QuantityProrateGranularity
      ,sp.[PricingModelTypeId] as PricingModelType
      ,sp.[EarningIntervalId] as EarningInterval
	  ,sp.CustomServiceDateIntervalId as CustomServiceDateInterval
	  ,sp.CustomServiceDateProjectionId as CustomServiceDateProjection
FROM [dbo].[DraftSubscriptionProductCharge] dspc
INNER JOIN #DraftCharges dc ON dc.Id = dspc.Id
INNER JOIN [dbo].SubscriptionProduct sp on sp.Id = dspc.SubscriptionProductId

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
  INNER JOIN [dbo].[DraftSubscriptionProductCharge] dspc ON sm.Id = dspc.ScheduledMigrationId
	INNER JOIN #DraftCharges dc ON dc.Id = dspc.Id

DROP TABLE #DraftInvoices
DROP TABLE #DraftCharges

GO

