CREATE PROCEDURE [dbo].[usp_GetFullProductItems]
	@productItemIds nvarchar(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @productItems table
	(
		SortOrder INT
		,ProductItemId bigint
	)

	INSERT INTO @productItems (SortOrder,ProductItemId)
	select 
	ROW_NUMBER() OVER (ORDER BY (SELECT 100)) AS [SortOrder]
	,Data 
	FROM dbo.Split (@productItemIds,'|')

	SELECT 
		piT.*
		,piT.[StatusId] as [Status]
	 FROM [dbo].[ProductItem] piT
	INNER JOIN @productItems [pi] ON Id = [pi].ProductItemId
	ORDER BY [pi].SortOrder

	Select 
		p.* 
		, p.StatusId as [Status]
		, p.PricingModelTypeId as [PricingModelType]
		, p.EarningTimingIntervalId as [EarningTimingInterval]
		, p.EarningTimingTypeId as [EarningTimingType]
	from [dbo].[Purchase] p
	INNER JOIN [dbo].[PurchaseProductItem] ppi on ppi.PurchaseId = p.Id
	INNER JOIN @productItems [pi] ON ppi.Id = [pi].ProductItemId

	Select 	
		spi.Id,
		spi.SubscriptionProductId,
		spi.SubscriptionProductActivityJournalId
	from [dbo].[SubscriptionProductItem] spi 
	INNER JOIN @productItems [pi] ON spi.Id = [pi].ProductItemId

	Select 
		sp.*
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
	from [dbo].[SubscriptionProduct] sp
	INNER JOIN [dbo].[SubscriptionProductItem] spi on spi.SubscriptionProductId = sp.Id
	INNER JOIN @productItems [pi] ON spi.Id = [pi].ProductItemId

	Select 
		s.*
	    ,s.[StatusId] as [Status]
		,s.[IntervalId] as Interval
	from [dbo].[Subscription] s
	INNER JOIN [dbo].[SubscriptionProduct] sp on sp.SubscriptionId = s.Id
	INNER JOIN [dbo].[SubscriptionProductItem] spi on spi.SubscriptionProductId = sp.Id
	INNER JOIN @productItems [pi] ON spi.Id = [pi].ProductItemId

	SELECT c.*
		, c.AccountStatusId as AccountStatus
		, c.NetsuiteEntityTypeId as NetsuiteEntityType
		, c.QuickBooksLatchTypeId as QuickBooksLatchType
		, c.SalesforceAccountTypeId as SalesforceAccountType
		, c.SalesforceSynchStatusId as SalesforceSynchStatus
		, c.StatusId as [Status]
		, c.TitleId as [Title]
	FROM [dbo].[Customer] c
	INNER JOIN [dbo].[ProductItem] piT on piT.CustomerId = c.Id
	INNER JOIN @productItems [pi] ON piT.Id = [pi].ProductItemId

	SELECT * FROM CustomerAcquisition ca
	INNER JOIN [dbo].[Customer] c on c.Id = ca.Id
	INNER JOIN [dbo].[ProductItem] piT on piT.CustomerId = c.Id
	INNER JOIN @productItems [pi] ON piT.Id = [pi].ProductItemId

	SELECT * FROM CustomerReference ca
	INNER JOIN [dbo].[Customer] c on c.Id = ca.Id
	INNER JOIN [dbo].[ProductItem] piT on piT.CustomerId = c.Id
	INNER JOIN @productItems [pi] ON piT.Id = [pi].ProductItemId

	SELECT * FROM CustomerCredential ca
	INNER JOIN [dbo].[Customer] c on c.Id = ca.Id
	INNER JOIN [dbo].[ProductItem] piT on piT.CustomerId = c.Id
	INNER JOIN @productItems [pi] ON piT.Id = [pi].ProductItemId

	SELECT sc1.*
		  ,sc1.[TypeId] as [Type]
		  ,sc1.[StatusId] as [Status]
	  FROM [dbo].[SalesTrackingCode] sc1
	INNER JOIN CustomerReference cr ON sc1.Id = cr.SalesTrackingCode1Id
	INNER JOIN [dbo].[Customer] c on c.Id = cr.Id
	INNER JOIN [dbo].[ProductItem] piT on piT.CustomerId = c.Id
	INNER JOIN @productItems [pi] ON piT.Id = [pi].ProductItemId
	UNION ALL
	SELECT sc2.*
		  ,sc2.[TypeId] as [Type]
		  ,sc2.[StatusId] as [Status]
	  FROM [dbo].[SalesTrackingCode] sc2
	INNER JOIN CustomerReference cr ON sc2.Id = cr.SalesTrackingCode2Id
	INNER JOIN [dbo].[Customer] c on c.Id = cr.Id
	INNER JOIN [dbo].[ProductItem] piT on piT.CustomerId = c.Id
	INNER JOIN @productItems [pi] ON piT.Id = [pi].ProductItemId
	UNION ALL
	SELECT sc3.*
		  ,sc3.[TypeId] as [Type]
		  ,sc3.[StatusId] as [Status]
	  FROM [dbo].[SalesTrackingCode] sc3
	INNER JOIN CustomerReference cr ON sc3.Id = cr.SalesTrackingCode3Id
	INNER JOIN [dbo].[Customer] c on c.Id = cr.Id
	INNER JOIN [dbo].[ProductItem] piT on piT.CustomerId = c.Id
	INNER JOIN @productItems [pi] ON piT.Id = [pi].ProductItemId
	UNION ALL
	SELECT sc4.*
		  ,sc4.[TypeId] as [Type]
		  ,sc4.[StatusId] as [Status]
	  FROM [dbo].[SalesTrackingCode] sc4
	INNER JOIN CustomerReference cr ON sc4.Id = cr.SalesTrackingCode4Id
	INNER JOIN [dbo].[Customer] c on c.Id = cr.Id
	INNER JOIN [dbo].[ProductItem] piT on piT.CustomerId = c.Id
	INNER JOIN @productItems [pi] ON piT.Id = [pi].ProductItemId
	UNION ALL
	SELECT sc5.*
		  ,sc5.[TypeId] as [Type]
		  ,sc5.[StatusId] as [Status]
	  FROM [dbo].[SalesTrackingCode] sc5
	INNER JOIN CustomerReference cr ON sc5.Id = cr.SalesTrackingCode5Id
	INNER JOIN [dbo].[Customer] c on c.Id = cr.Id
	INNER JOIN [dbo].[ProductItem] piT on piT.CustomerId = c.Id
	INNER JOIN @productItems [pi] ON piT.Id = [pi].ProductItemId

	SELECT spo.* FROM SubscriptionProductOverride spo
	INNER JOIN SubscriptionProduct sp ON sp.Id = spo.Id
	INNER JOIN [dbo].[SubscriptionProductItem] spi on spi.SubscriptionProductId = sp.Id
	INNER JOIN @productItems [pi] ON spi.Id = [pi].ProductItemId

	SELECT so.* FROM SubscriptionOverride so
	INNER JOIN [dbo].[SubscriptionProduct] sp on sp.SubscriptionId = so.Id
	INNER JOIN [dbo].[SubscriptionProductItem] spi on spi.SubscriptionProductId = sp.Id
	INNER JOIN @productItems [pi] ON spi.Id = [pi].ProductItemId

	SELECT 
		p.*
		,p.[ProductTypeId] as ProductType
		,[ProductStatusId] as [Status]
	FROM [dbo].[Product] p
	INNER JOIN SubscriptionProduct sp ON p.Id = sp.ProductId
	INNER JOIN [dbo].[SubscriptionProductItem] spi on spi.SubscriptionProductId = sp.Id
	INNER JOIN @productItems [pi] ON spi.Id = [pi].ProductItemId
	UNION ALL
	SELECT
		p.*
		,p.[ProductTypeId] as ProductType
		,[ProductStatusId] as [Status]
	FROM [dbo].[Product] p
	INNER JOIN Purchase pu ON p.Id = pu.ProductId
	INNER JOIN PurchaseProductItem ppu ON ppu.PurchaseId = pu.Id
	INNER JOIN @productItems [pi] ON ppu.Id = [pi].ProductItemId

	--Create custom mapping table for mapping product items to purchases
	Select 
		p.Id as PurchaseId,
		[pi].ProductItemId as ProductItemId
	from [dbo].[Purchase] p
	INNER JOIN [dbo].[PurchaseProductItem] ppi on ppi.PurchaseId = p.Id
	INNER JOIN @productItems [pi] ON ppi.Id = [pi].ProductItemId

END

GO

