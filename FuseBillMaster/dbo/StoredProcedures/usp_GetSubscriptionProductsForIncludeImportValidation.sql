
CREATE procedure [dbo].[usp_GetSubscriptionProductsForIncludeImportValidation]
       @AccountId bigint
	   , @SubscriptionProducts IDList READONLY
AS

	SELECT 
		sp.Id as SubscriptionProductId
		, s.Id as SubscriptionId
		, s.BillingPeriodDefinitionId
		, c.Id as CustomerId
	INTO #SubscriptionProductsWithForeignKeys
	FROM @SubscriptionProducts sps
	INNER JOIN SubscriptionProduct sp ON sp.Id = sps.Id
	INNER JOIN Subscription s ON s.Id = sp.SubscriptionId
	INNER JOIN Customer c ON c.Id = s.CustomerId
		AND c.AccountId = @AccountId

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
	INNER JOIN #SubscriptionProductsWithForeignKeys sps ON sp.Id = sps.SubscriptionProductId

	SELECT s.*
		,s.[StatusId] as [Status]
		,s.[IntervalId] as Interval
	FROM Subscription s
	INNER JOIN #SubscriptionProductsWithForeignKeys sp ON s.Id = sp.SubscriptionId

	SELECT c.*
		, c.AccountStatusId as AccountStatus
		, c.NetsuiteEntityTypeId as NetsuiteEntityType
		, c.QuickBooksLatchTypeId as QuickBooksLatchType
		, c.SalesforceAccountTypeId as SalesforceAccountType
		, c.SalesforceSynchStatusId as SalesforceSynchStatus
		, c.StatusId as [Status]
		, c.TitleId as [Title]
	FROM Customer c
	INNER JOIN #SubscriptionProductsWithForeignKeys sp ON c.Id = sp.CustomerId

	SELECT bpd.*
		,[IntervalId] as Interval
		,[BillingPeriodTypeId] as BillingPeriodType
	FROM BillingPeriodDefinition bpd
	INNER JOIN #SubscriptionProductsWithForeignKeys sp ON bpd.Id = sp.BillingPeriodDefinitionId

GO

