
CREATE PROCEDURE [dbo].[usp_GetFullDraftInvoices]

	@draftInvoices AS dbo.IDList READONLY,
	@accountId bigint
AS
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

SELECT d.*
	, DraftInvoiceStatusId as DraftInvoiceStatus
FROM [dbo].[DraftInvoice] d
INNER JOIN @draftInvoices di ON d.Id = di.Id

SELECT
	bp.*
	, bp.PeriodStatusId as PeriodStatus
FROM [dbo].[BillingPeriod] bp
INNER JOIN [dbo].[DraftInvoice] d ON bp.Id = d.BillingPeriodId
INNER JOIN @draftInvoices di ON d.Id = di.Id

SELECT dt.Id
	, dt.TaxRuleId
	, dt.DraftInvoiceId
	, dt.DraftChargeId
	, dt.Amount
	, dt.CurrencyId
FROM [dbo].[DraftTax] dt
INNER JOIN @draftInvoices di ON dt.DraftInvoiceId = di.Id

SELECT ds.*
FROM [dbo].[DraftPaymentSchedule] ds
INNER JOIN @draftInvoices di ON ds.DraftInvoiceId = di.Id

SELECT dc.*
	, dc.TransactionTypeId as TransactionType
	, dc.StatusId as [Status]
	, dc.EarningTimingTypeId as EarningTimingType
	, dc.EarningTimingIntervalId as EarningTimingInterval
FROM [dbo].[DraftCharge] dc
INNER JOIN @draftInvoices di ON dc.DraftInvoiceId = di.Id

SELECT 
	dd.DiscountTypeId as DiscountType    
	 , dd.TransactionTypeId as TransactionType 
	 ,*
FROM [dbo].[DraftDiscount] dd
INNER JOIN [dbo].[DraftCharge] dc ON dc.Id = dd.DraftChargeId
INNER JOIN @draftInvoices di ON dc.DraftInvoiceId = di.Id

SELECT p.*
	, p.StatusId as [Status]
	, p.PricingModelTypeId as PricingModelType
	, p.EarningTimingTypeId as EarningTimingType
	, p.EarningTimingIntervalId as EarningTimingInterval
FROM [dbo].[DraftPurchaseCharge] dpc
INNER JOIN [dbo].[Purchase] p ON p.Id = dpc.PurchaseId
INNER JOIN [dbo].[DraftCharge] dc ON dc.Id = dpc.Id
INNER JOIN @draftInvoices di ON dc.DraftInvoiceId = di.Id

SELECT pes.*
	, pes.EarningScheduleIntervalId as EarningScheduleInterval
FROM [dbo].[DraftPurchaseCharge] dpc
INNER JOIN [dbo].[Purchase] p ON p.Id = dpc.PurchaseId
INNER JOIN [dbo].[DraftCharge] dc ON dc.Id = dpc.Id
INNER JOIN @draftInvoices di ON dc.DraftInvoiceId = di.Id
INNER JOIN [dbo].[PurchaseEarningSchedule] pes ON pes.PurchaseId = p.Id

SELECT peds.*
FROM [dbo].[DraftPurchaseCharge] dpc
INNER JOIN [dbo].[Purchase] p ON p.Id = dpc.PurchaseId
INNER JOIN [dbo].[DraftCharge] dc ON dc.Id = dpc.Id
INNER JOIN @draftInvoices di ON dc.DraftInvoiceId = di.Id
INNER JOIN [dbo].[PurchaseEarningSchedule] pes ON pes.PurchaseId = p.Id
INNER JOIN [dbo].[PurchaseEarningDiscountSchedule] peds ON peds.PurchaseEarningScheduleId = pes.Id

SELECT dspc.*
FROM [dbo].[DraftSubscriptionProductCharge] dspc
INNER JOIN [dbo].[DraftCharge] dc ON dc.Id = dspc.Id
INNER JOIN @draftInvoices di ON dc.DraftInvoiceId = di.Id

SELECT spajdc.*
FROM [dbo].[SubscriptionProductActivityJournalDraftCharge] spajdc
INNER JOIN [dbo].[DraftSubscriptionProductCharge] dspc ON dspc.Id = spajdc.DraftChargeId
INNER JOIN [dbo].[DraftCharge] dc ON dc.Id = dspc.Id
INNER JOIN @draftInvoices di ON dc.DraftInvoiceId = di.Id

SELECT dcpi.*
FROM [dbo].[DraftChargeProductItem] dcpi
INNER JOIN [dbo].[DraftCharge] dc ON dc.Id = dcpi.DraftChargeId
INNER JOIN @draftInvoices di ON dc.DraftInvoiceId = di.Id

SELECT 
      i.[StatusId] as [Status]
	  ,i.*
  FROM [dbo].[ProductItem] i
INNER JOIN [dbo].[DraftChargeProductItem] dcpi ON dcpi.ProductItemId = i.Id
INNER JOIN [dbo].[DraftCharge] dc ON dc.Id = dcpi.DraftChargeId
INNER JOIN @draftInvoices di ON dc.DraftInvoiceId = di.Id

SELECT dpc.*
FROM [dbo].[DraftPurchaseCharge] dpc
INNER JOIN [dbo].[DraftCharge] dc ON dc.Id = dpc.Id
INNER JOIN @draftInvoices di ON dc.DraftInvoiceId = di.Id

SELECT p.*
      ,p.[ProductTypeId] as ProductType
      ,p.[ProductStatusId] as Status
FROM [dbo].[Product] p
INNER JOIN Purchase pu ON p.Id = pu.ProductId
INNER JOIN [dbo].[DraftPurchaseCharge] dpc ON pu.Id = dpc.PurchaseId
INNER JOIN [dbo].[DraftCharge] dc ON dc.Id = dpc.Id
INNER JOIN @draftInvoices di ON dc.DraftInvoiceId = di.Id
UNION ALL
SELECT p.*
      ,p.[ProductTypeId] as ProductType
      ,p.[ProductStatusId] as Status
FROM [dbo].[Product] p
INNER JOIN SubscriptionProduct sp ON p.Id = sp.ProductId
INNER JOIN [dbo].[DraftSubscriptionProductCharge] dpc ON sp.Id = dpc.SubscriptionProductId
INNER JOIN [dbo].[DraftCharge] dc ON dc.Id = dpc.Id
INNER JOIN @draftInvoices di ON dc.DraftInvoiceId = di.Id

SELECT dpc.*
FROM [dbo].[DraftChargeTier] dpc
INNER JOIN [dbo].[DraftCharge] dc ON dc.Id = dpc.DraftChargeId
INNER JOIN @draftInvoices di ON dc.DraftInvoiceId = di.Id

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
FROM SubscriptionProduct sp
INNER JOIN [dbo].[DraftSubscriptionProductCharge] dpc ON sp.Id = dpc.SubscriptionProductId
INNER JOIN [dbo].[DraftCharge] dc ON dc.Id = dpc.Id
INNER JOIN @draftInvoices di ON dc.DraftInvoiceId = di.Id

SELECT DISTINCT s.*
      ,s.[StatusId] as [Status]
      ,s.[IntervalId] as Interval
FROM [dbo].[Subscription] s
INNER JOIN SubscriptionProduct sp on s.Id = sp.SubscriptionId
INNER JOIN [dbo].[DraftSubscriptionProductCharge] dpc ON sp.Id = dpc.SubscriptionProductId
INNER JOIN [dbo].[DraftCharge] dc ON dc.Id = dpc.Id
INNER JOIN @draftInvoices di ON dc.DraftInvoiceId = di.Id

GO

