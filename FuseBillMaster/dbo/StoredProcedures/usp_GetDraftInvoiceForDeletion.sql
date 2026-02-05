
CREATE   PROCEDURE [dbo].[usp_GetDraftInvoiceForDeletion]
	@draftInvoiceId bigint
AS
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
SELECT *
	, DraftInvoiceStatusId as DraftInvoiceStatus
FROM [dbo].[DraftInvoice] 
WHERE Id = @draftInvoiceId

SELECT c.*
	,TitleId as Title
	,StatusId as [Status]
	,AccountStatusId as AccountStatus
	,CurrencyId as Currency
	,NetsuiteSynchStatusId as NetsuiteSynchStatus
	,NetsuiteEntityTypeId as NetsuiteEntityType
	,SalesforceAccountTypeId as SalesforceAccountType
	,SalesforceSynchStatusId as SalesforceSynchStatus
FROM dbo.Customer c
INNER JOIN dbo.DraftInvoice di
ON di.CustomerId = c.Id
WHERE di.Id = @draftInvoiceId

SELECT cap.*
FROM dbo.CustomerAddressPreference cap
INNER JOIN dbo.DraftInvoice di
ON di.CustomerId = cap.Id
WHERE di.Id = @draftInvoiceId

SELECT cbs.*
	,cbs.TermId as Term
	,IntervalId as Interval
	,CustomerCancelOptionId as CustomerCancelOption
	,CustomerServiceStartOptionId as CustomerServiceStartOption
	,RechargeTypeId as RechargeType
	,HierarchySuspendOptionId as HierarchySuspendOption
	,AutoCollectSettingTypeId as AutoCollectionSettingType
FROM dbo.CustomerBillingSetting cbs
INNER JOIN dbo.DraftInvoice di
ON di.CustomerId = cbs.Id
WHERE di.Id = @draftInvoiceId

SELECT dc.*
	, dc.TransactionTypeId as TransactionType
	, dc.StatusId as [Status]
	, dc.EarningTimingTypeId as EarningTimingType
	, dc.EarningTimingIntervalId as EarningTimingInterval
FROM dbo.DraftCharge dc
WHERE dc.DraftInvoiceId = @draftInvoiceId

SELECT dt.*
FROM dbo.DraftTax dt
WHERE dt.DraftInvoiceId = @draftInvoiceId

SELECT tr.*
FROM dbo.TaxRule tr
INNER JOIN dbo.DraftTax dt
ON dt.TaxRuleId = tr.Id
WHERE dt.DraftInvoiceId = @draftInvoiceId

SELECT spajdc.*
FROM dbo.SubscriptionProductActivityJournalDraftCharge spajdc
INNER JOIN dbo.DraftCharge dc
ON dc.Id = spajdc.DraftChargeId
WHERE dc.DraftInvoiceId = @draftInvoiceId

SELECT dd.*
	, dd.DiscountTypeId as DiscountType
	, dd.TransactionTypeId as TransactionType
FROM dbo.DraftDiscount dd
INNER JOIN dbo.DraftCharge dc
ON dc.Id = dd.DraftChargeId
WHERE dc.DraftInvoiceId = @draftInvoiceId

SELECT dps.*
FROM dbo.DraftPaymentSchedule dps
WHERE dps.DraftInvoiceId = @draftInvoiceId

SELECT dspc.*
FROM dbo.DraftSubscriptionProductCharge dspc
INNER JOIN dbo.DraftCharge dc
ON dc.Id = dspc.Id
WHERE dc.DraftInvoiceId = @draftInvoiceId

SELECT s.*
      ,s.[StatusId] as [Status]
      ,s.[IntervalId] as Interval
FROM dbo.Subscription s
INNER JOIN dbo.SubscriptionProduct sp
ON s.Id = sp.SubscriptionId
INNER JOIN dbo.DraftSubscriptionProductCharge dspc
ON sp.Id = dspc.SubscriptionProductId
INNER JOIN dbo.DraftCharge dc
ON dc.Id = dspc.Id
WHERE dc.DraftInvoiceId = @draftInvoiceId

SELECT sp.*
      ,sp.[StatusId] as [Status]
      ,sp.[EarningTimingTypeId] as EarningTimingType
      ,sp.[EarningTimingIntervalId] as EarningTimingInterval
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
FROM SubscriptionProduct sp 
INNER JOIN DraftSubscriptionProductCharge dspc 
ON dspc.SubscriptionProductId = sp.Id
INNER JOIN DraftCharge dc 
ON dc.Id = dspc.Id
WHERE dc.DraftInvoiceId = @draftInvoiceId

SELECT p.*
      ,p.[ProductTypeId] as ProductType
      ,p.[ProductStatusId] as [Status]
FROM (
	SELECT p.Id 
	FROM dbo.[Product] p
	INNER JOIN dbo.SubscriptionProduct sp ON p.Id = sp.ProductId
	INNER JOIN dbo.DraftSubscriptionProductCharge dspc ON sp.Id = dspc.SubscriptionProductId
	INNER JOIN dbo.DraftCharge dc ON dc.Id = dspc.Id
	WHERE dc.DraftInvoiceId = @draftInvoiceId

	UNION 

	SELECT p.Id 
	FROM dbo.[Product] p INNER JOIN dbo.Purchase pur ON p.Id = pur.ProductId
	INNER JOIN dbo.DraftPurchaseCharge dpc ON pur.Id = dpc.PurchaseId
	INNER JOIN dbo.DraftCharge dc ON dc.Id = dpc.Id
	WHERE dc.DraftInvoiceId = @draftInvoiceId
) AS q
INNER JOIN dbo.[Product] p ON p.Id = q.Id

SELECT dcpi.*
FROM dbo.DraftChargeProductItem dcpi
INNER JOIN DraftCharge dc
ON dc.Id = dcpi.DraftChargeId
WHERE dc.DraftInvoiceId = @draftInvoiceId

SELECT pri.*
	,pri.StatusId as [Status]
FROM dbo.ProductItem pri
INNER JOIN dbo.DraftChargeProductItem dcpi
ON dcpi.ProductItemId = pri.Id
INNER JOIN DraftCharge dc
ON dc.Id = dcpi.DraftChargeId
WHERE dc.DraftInvoiceId = @draftInvoiceId

SELECT dpc.*
FROM [dbo].[DraftPurchaseCharge] dpc
INNER JOIN DraftCharge dc ON dc.Id = dpc.Id
WHERE dc.DraftInvoiceId = @draftInvoiceId

SELECT p.*
	, p.StatusId as [Status]
	, p.PricingModelTypeId as PricingModelType
	, p.EarningTimingTypeId as EarningTimingType
	, p.EarningTimingIntervalId as EarningTimingInterval
FROM [dbo].[DraftPurchaseCharge] dpc
INNER JOIN [dbo].[Purchase] p ON p.Id = dpc.PurchaseId
INNER JOIN DraftCharge dc ON dc.Id = dpc.Id
WHERE dc.DraftInvoiceId = @draftInvoiceId

GO

