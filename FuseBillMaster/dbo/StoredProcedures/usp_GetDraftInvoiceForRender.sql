
CREATE PROCEDURE [dbo].[usp_GetDraftInvoiceForRender]
	@draftInvoiceId bigint,
	@accountId bigint
AS
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
SELECT *
	, DraftInvoiceStatusId as DraftInvoiceStatus
FROM [dbo].[DraftInvoice] 
where Id = @draftInvoiceId

SELECT Id
	, TaxRuleId
	, DraftInvoiceId
	, DraftChargeId
	, Amount
	, CurrencyId
FROM [dbo].[DraftTax] 
where DraftInvoiceId = @draftInvoiceId

SELECT *
FROM [dbo].[DraftPaymentSchedule]
where DraftInvoiceId = @draftInvoiceId

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
where dc.DraftInvoiceId = @draftInvoiceId

SELECT 
	dd.DiscountTypeId as DiscountType    
	 , dd.TransactionTypeId as TransactionType 
	 ,*
FROM [dbo].[DraftDiscount] dd
INNER JOIN [dbo].[DraftCharge] dc ON dc.Id = dd.DraftChargeId
where dc.DraftInvoiceId = @draftInvoiceId

--SELECT p.Id
--	, p.ProductId
--	, p.StatusId as [Status]
--	, p.CustomerId
--	, p.Quantity
--	, p.Name
--	, p.[Description]
--	, p.CreatedTimestamp
--	, p.ModifiedTimestamp
--	, p.EffectiveTimestamp
--	, p.PurchaseTimestamp
--	, p.PricingModelTypeId as PricingModelType
--	, p.Amount
--	, p.TaxableAmount
--	, p.IsEarnedImmediately
--	, p.EarningInterval
--	, p.EarningNumberOfInterval
--	, p.IsTrackingItems
--	, p.EarningTimingTypeId as EarningTimingType
--	, p.EarningTimingIntervalId as EarningTimingInterval
--	, p.SalesforceId
--	, p.CancellationTimestamp
--FROM [dbo].[DraftPurchaseCharge] dpc
--INNER JOIN [dbo].[Purchase] p ON p.Id = dpc.PurchaseId
--INNER JOIN [dbo].[DraftCharge] dc ON dc.Id = dpc.Id
--where dc.DraftInvoiceId = @draftInvoiceId

SELECT dpc.*
FROM [dbo].[DraftPurchaseCharge] dpc
INNER JOIN [dbo].[DraftCharge] dc ON dc.Id = dpc.Id
where dc.DraftInvoiceId = @draftInvoiceId

SELECT dspc.*
FROM [dbo].[DraftSubscriptionProductCharge] dspc
INNER JOIN [dbo].[DraftCharge] dc ON dc.Id = dspc.Id
where dc.DraftInvoiceId = @draftInvoiceId

SELECT dcpi.*
FROM [dbo].[DraftChargeProductItem] dcpi
INNER JOIN [dbo].[DraftCharge] dc ON dc.Id = dcpi.DraftChargeId
where dc.DraftInvoiceId = @draftInvoiceId

SELECT 
      i.[StatusId] as [Status]
	  ,i.*
  FROM [dbo].[ProductItem] i
INNER JOIN [dbo].[DraftChargeProductItem] dcpi ON dcpi.ProductItemId = i.Id
INNER JOIN [dbo].[DraftCharge] dc ON dc.Id = dcpi.DraftChargeId
where dc.DraftInvoiceId = @draftInvoiceId



SELECT p.*
      ,p.[ProductTypeId] as ProductType
      ,p.[ProductStatusId] as Status
FROM [dbo].[Product] p
INNER JOIN Purchase pu ON p.Id = pu.ProductId
INNER JOIN [dbo].[DraftPurchaseCharge] dpc ON pu.Id = dpc.PurchaseId
INNER JOIN [dbo].[DraftCharge] dc ON dc.Id = dpc.Id
where dc.DraftInvoiceId = @draftInvoiceId
UNION ALL
SELECT p.*
      ,p.[ProductTypeId] as ProductType
      ,p.[ProductStatusId] as Status
FROM [dbo].[Product] p
INNER JOIN SubscriptionProduct sp ON p.Id = sp.ProductId
INNER JOIN [dbo].[DraftSubscriptionProductCharge] dpc ON sp.Id = dpc.SubscriptionProductId
INNER JOIN [dbo].[DraftCharge] dc ON dc.Id = dpc.Id
where dc.DraftInvoiceId = @draftInvoiceId

SELECT dpc.*
FROM [dbo].[DraftChargeTier] dpc
INNER JOIN [dbo].[DraftCharge] dc ON dc.Id = dpc.DraftChargeId
where dc.DraftInvoiceId = @draftInvoiceId

SELECT s.*
      ,s.[StatusId] as [Status]
      ,s.[IntervalId] as Interval
  FROM [dbo].[Subscription] s
inner join SubscriptionProduct sp on sp.SubscriptionId = s.Id
inner join DraftSubscriptionProductCharge dspc on dspc.SubscriptionProductId = sp.Id
inner join DraftCharge dc on dc.Id = dspc.Id
where dc.DraftInvoiceId = @draftInvoiceId

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
from SubscriptionProduct sp 
inner join DraftSubscriptionProductCharge dspc on dspc.SubscriptionProductId = sp.Id
inner join DraftCharge dc on dc.Id = dspc.Id
where dc.DraftInvoiceId = @draftInvoiceId

Select so.* from SubscriptionOverride so
inner join SubscriptionProduct sp on sp.SubscriptionId = so.Id
inner join DraftSubscriptionProductCharge dspc on dspc.SubscriptionProductId = sp.Id
inner join DraftCharge dc on dc.Id = dspc.Id
where dc.DraftInvoiceId = @draftInvoiceId

SELECT p.*
	, p.StatusId as [Status]
	, p.PricingModelTypeId as [PricingModelType]
	, p.EarningTimingIntervalId as [EarningTimingInterval]
	, p.EarningTimingTypeId as [EarningTimingType]
FROM Purchase p
inner join DraftPurchaseCharge dpc on dpc.PurchaseId = p.Id
inner join DraftCharge dc on dc.Id = dpc.Id
where dc.DraftInvoiceId = @draftInvoiceId

SELECT c.*
	, c.AccountStatusId as AccountStatus
	, c.NetsuiteEntityTypeId as NetsuiteEntityType
	, c.QuickBooksLatchTypeId as QuickBooksLatchType
	, c.SalesforceAccountTypeId as SalesforceAccountType
	, c.SalesforceSynchStatusId as SalesforceSynchStatus
	, c.StatusId as [Status]
	, c.TitleId as [Title]
FROM [dbo].[Customer] c
inner join DraftInvoice di on di.CustomerId = c.Id
where di.Id = @draftInvoiceId

SELECT cbs.*
	, cbs.TermId as [Term]
	, cbs.IntervalId as [Interval]
	, cbs.CustomerServiceStartOptionId as [CustomerServiceStartOption]
	, cbs.RechargeTypeId as [RechargeType]
	, cbs.HierarchySuspendOptionId as [HierarchySuspendOption]
FROM [dbo].[CustomerBillingSetting] cbs
inner join DraftInvoice di on di.CustomerId = cbs.Id
where di.Id = @draftInvoiceId

SELECT bp.*
	, bp.PeriodStatusId as PeriodStatus
FROM BillingPeriod bp
inner join DraftInvoice di on di.BillingPeriodId = bp.Id
where di.Id = @draftInvoiceId

SELECT
	bpd.*
	,bpd.[IntervalId] as Interval
	,bpd.[BillingPeriodTypeId] as BillingPeriodType
FROM [dbo].[BillingPeriodDefinition] bpd
inner join BillingPeriod bp ON bpd.Id = bp.BillingPeriodDefinitionId
inner join DraftInvoice di on di.BillingPeriodId = bp.Id
where di.Id = @draftInvoiceId

SELECT 
	cis.*
    ,cis.[TrackedItemDisplayFormatId] as TrackedItemDisplayFormat
	FROM CustomerInvoiceSetting cis
	inner join DraftInvoice di on di.CustomerId = cis.Id
where di.Id = @draftInvoiceId

SELECT * FROM CustomerAddressPreference cas
	inner join DraftInvoice di on di.CustomerId = cas.Id
where di.Id = @draftInvoiceId

select *, AddressTypeId as AddressType, Country as Country1, State as State1 from [Address] a
	inner join DraftInvoice di on di.CustomerId = a.CustomerAddressPreferenceId
where di.Id = @draftInvoiceId

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
	INNER JOIN DraftCharge dc ON dc.Id = dspc.Id

SELECT 
pes.*,
pes.EarningScheduleIntervalId as EarningScheduleInterval
FROM PurchaseEarningSchedule pes
INNER JOIN DraftPurchaseCharge dpc on pes.PurchaseId = dpc.PurchaseId
INNER JOIN DraftCharge dc on dc.Id = dpc.Id
Where dc.DraftInvoiceId = @draftInvoiceId

GO

