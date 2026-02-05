
CREATE   PROCEDURE [dbo].[usp_GetFullHostedPageManagedOfferings]
	@ids AS dbo.IDList READONLY,
	@accountId bigint = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	declare @offerings table
	(
	[SortOrder] int,
	OfferingId bigint,
	HostedPageId bigint
	)

	INSERT INTO @offerings ([SortOrder], OfferingId, HostedPageId)
		SELECT
			ROW_NUMBER() OVER (ORDER BY (SELECT 100)) AS [SortOrder],
			ids.Id, hpo.HostedPageId
		FROM @ids ids
		INNER JOIN HostedPageManagedOffering hpo ON hpo.Id = ids.Id
		WHERE EXISTS(
			SELECT 1  
			FROM HostedPage hp 
			WHERE hp.Id = hpo.HostedPageId
				AND hp.AccountId = ISNULL(@accountId,hp.AccountId)
		)

	SELECT
		hpo.*
	FROM [dbo].[HostedPageManagedOffering] hpo
	INNER JOIN @offerings ON OfferingId = hpo.Id
	ORDER BY SortOrder

	SELECT
		poff.*
	FROM [dbo].[HostedPageManagedOfferingPlan] poff
	INNER JOIN @offerings ON OfferingId = poff.HostedPageManagedOfferingId
	INNER JOIN dbo.[plan] p on p.Id = poff.PlanId
	WHERE p.IsDeleted = 0

	SELECT 
		hpmopf.*
	FROM [dbo].HostedPageManagedOfferingPlanFrequency hpmopf
	INNER JOIN PlanFrequency pf ON pf.PlanFrequencyUniqueId = hpmopf.PlanFrequencyKeyId
	INNER JOIN dbo.HostedPageManagedOfferingPlan hpmop ON hpmop.Id = hpmopf.[HostedPageManagedOfferingPlanId]
	INNER JOIN @offerings ON OfferingId = hpmop.HostedPageManagedOfferingId
	ORDER BY pf.Interval ASC, pf.NumberOfIntervals ASC
	

	SELECT
		hpmopf.*
	FROM [dbo].[HostedPageManagedOfferingPlanProduct] hpmopf
	INNER JOIN [dbo].[HostedPageManagedOfferingPlan] hpmop on hpmopf.HostedPageManagedOfferingPlanId = hpmop.Id
	INNER JOIN @offerings ON OfferingId = hpmop.HostedPageManagedOfferingId

	SELECT
		hp.*
		, hp.[HostedPageTypeId] as [HostedPageType]
		, hp.[HostedPageDomainId] as [HostedPageDomain]
		, hp.[HostedPageStatusId] as [HostedPageStatus] 
		, hp.EnableSingleSignOn as [EnableSingleSignOn]
	FROM [dbo].[HostedPage] hp 
	INNER JOIN @offerings ON HostedPageId = hp.Id

	SELECT
		mp.*
		, mp.[StatusTypeId] as [StatusType]
	FROM [dbo].[HostedPageManagedOffering] hpo
	INNER JOIN @offerings ON OfferingId = hpo.Id
	INNER JOIN [dbo].[HostedPageManagedSelfServicePortal] mp ON mp.Id = hpo.HostedPageManagedSelfServicePortalId

	SELECT
		p.*
		, p.[StatusId] as [Status]
	FROM [dbo].[Plan] p
	INNER JOIN [dbo].[HostedPageManagedOfferingPlan] poff ON p.Id = poff.PlanId
	INNER JOIN @offerings ON OfferingId = poff.HostedPageManagedOfferingId
	WHERE p.IsDeleted = 0

	SELECT 
		pr.*
	FROM [dbo].[PlanRevision] pr
	INNER JOIN [dbo].[Plan] p ON p.Id = pr.PlanId
		AND pr.IsActive = 1
	INNER JOIN [dbo].[HostedPageManagedOfferingPlan] poff ON p.Id = poff.PlanId
	INNER JOIN @offerings ON OfferingId = poff.HostedPageManagedOfferingId
	WHERE p.IsDeleted = 0

	SELECT
		pf.*
		, pf.[StatusId] as [Status]
	FROM [dbo].[PlanFrequency] pf
	INNER JOIN [dbo].[PlanRevision] pr ON pr.Id = pf.PlanRevisionId
		AND pr.IsActive = 1
	INNER JOIN [dbo].[Plan] p ON p.Id = pr.PlanId
	INNER JOIN [dbo].[HostedPageManagedOfferingPlan] poff ON p.Id = poff.PlanId
	INNER JOIN @offerings ON OfferingId = poff.HostedPageManagedOfferingId
	WHERE p.IsDeleted = 0

	SELECT
		hpol.*
	FROM [dbo].HostedPageManagedOfferingLabel hpol
	INNER JOIN @offerings ON OfferingId = hpol.Id

	DECLARE @PlanProductIds TABLE (Id bigint)

	INSERT INTO @PlanProductIds
	SELECT pp.Id
	FROM PlanProduct pp
	INNER JOIN HostedPageManagedOfferingPlanProduct hpmopf ON pp.PlanProductUniqueId = hpmopf.PlanProductKeyId
	INNER JOIN [dbo].[HostedPageManagedOfferingPlan] hpmop on hpmopf.HostedPageManagedOfferingPlanId = hpmop.Id
	INNER JOIN @offerings ON OfferingId = hpmop.HostedPageManagedOfferingId
	WHERE pp.StatusId = 1

	SELECT
		pp.*,
		pp.ResetTypeId as ResetType,
		pp.StatusId as [Status]
	FROM [dbo].[PlanProduct] pp
	INNER JOIN @PlanProductIds ppi ON ppi.Id = pp.Id

	SELECT
		o2c.*,
		o2c.PricingModelTypeId as PricingModelType,
		o2c.EarningTimingIntervalId as EarningTimingInterval,
		o2c.EarningTimingTypeId as EarningTimingType,
		potc.*,
		potc.RecurChargeTimingTypeId as RecurChargeTimingType,
		potc.RecurProrateGranularityId as RecurProrateGranularity,
		potc.QuantityChargeTimingTypeId as QuantityChargeTimingType,
		potc.QuantityProrateGranularityId as QuantityProrateGranularity,
		potc.CustomServiceDateIntervalId as CustomServiceDateInterval
		,CustomServiceDateProjectionId as CustomServiceDateProjection
	FROM OrderToCashCycle o2c
	INNER JOIN PlanOrderToCashCycle potc ON potc.Id = o2c.Id
	INNER JOIN @PlanProductIds ppi ON ppi.Id = potc.PlanProductId

	SELECT 
		qr.*
	FROM QuantityRange qr
	INNER JOIN PlanOrderToCashCycle potc ON potc.Id = qr.OrderToCashCycleId
	INNER JOIN @PlanProductIds ppi ON ppi.Id = potc.PlanProductId

	SELECT 
		pr.*
	FROM Price pr
	INNER JOIN QuantityRange qr ON qr.Id = pr.QuantityRangeId
	INNER JOIN PlanOrderToCashCycle potc ON potc.Id = qr.OrderToCashCycleId
	INNER JOIN @PlanProductIds ppi ON ppi.Id = potc.PlanProductId

	SELECT
		hpol.*
	FROM [dbo].HostedPageManagedOfferingPreviewPanel hpol
	INNER JOIN @offerings ON OfferingId = hpol.Id

	SELECT
		pofci.*
	FROM [dbo].[HostedPageManagedOfferingCustomerInformation] pofci
	INNER JOIN @offerings ON OfferingId = pofci.HostedPageManagedOfferingId

	SELECT *
	FROM Lookup.CustomerInformationField

	SELECT
		pofci.*
	FROM [dbo].[HostedPageManagedOfferingAvailableCountry] pofci
	INNER JOIN @offerings ON OfferingId = pofci.HostedPageManagedOfferingId

	SELECT
		pofci.*
	FROM [dbo].[HostedPageManagedOfferingAvailableSalesTrackingCode] pofci
	INNER JOIN @offerings ON OfferingId = pofci.HostedPageManagedOfferingId

	SELECT stc.*
		, stc.TypeId as [Type]
		, stc.StatusId as [Status]
	FROM SalesTrackingCode stc
	INNER JOIN [dbo].[HostedPageManagedOfferingAvailableSalesTrackingCode] pofci ON stc.Id = pofci.SalesTrackingCodeId
	INNER JOIN @offerings ON OfferingId = pofci.HostedPageManagedOfferingId

	SELECT
		poff.*
	FROM [dbo].[HostedPageManagedOfferingProduct] poff
	INNER JOIN @offerings ON OfferingId = poff.HostedPageManagedOfferingId

	SELECT
		p.*
		,p.[ProductTypeId] as ProductType
      ,p.[ProductStatusId] as [Status]
	FROM [dbo].[Product] p
	INNER JOIN [dbo].[HostedPageManagedOfferingProduct] poff ON p.Id = poff.ProductId
	INNER JOIN @offerings ON OfferingId = poff.HostedPageManagedOfferingId

	SELECT
		pofci.*
	FROM [dbo].[HostedPageManagedOfferingPaymentMethod] pofci
	INNER JOIN @offerings ON OfferingId = pofci.HostedPageManagedOfferingId

	SELECT *
	FROM Lookup.PaymentMethodField

	SELECT
		hpmolc.*
	FROM [dbo].HostedPageManagedOfferingLoginConfiguration hpmolc
	INNER JOIN @offerings ON OfferingId = hpmolc.Id

	select p.*
	from Pricebook p
	join PlanOrderToCashCycle po on po.PricebookId = p.Id
	join @PlanProductIds ppi ON ppi.Id = po.PlanProductId

	select *
	from PricebookEntry pe
	join Pricebook p on p.Id = pe.PricebookId
	join PlanOrderToCashCycle po on po.PricebookId = p.Id
	join @PlanProductIds ppi ON ppi.Id = po.PlanProductId

	select o2c.*,
	o2c.PricingModelTypeId as PricingModelType,
	o2c.EarningTimingIntervalId as EarningTimingInterval,
	o2c.EarningTimingTypeId as EarningTimingType
	from OrderToCashCycle o2c
	join PricebookEntry pe on pe.OrderToCashCycleId = o2c.Id
	join Pricebook p on p.Id = pe.PricebookId
	join PlanOrderToCashCycle potc on potc.PricebookId = p.Id
	join @PlanProductIds ppi ON ppi.Id = potc.PlanProductId

	select qr.*
	from QuantityRange qr
	join PricebookEntry pe on pe.OrderToCashCycleId = qr.OrderToCashCycleId
	join Pricebook p on p.Id = pe.PricebookId
	join PlanOrderToCashCycle potc on potc.PricebookId = p.Id
	join @PlanProductIds ppi ON ppi.Id = potc.PlanProductId

	select pr.*
	from Price pr
	join QuantityRange qr on qr.Id = pr.QuantityRangeId
	join PricebookEntry pe on pe.OrderToCashCycleId = qr.OrderToCashCycleId
	join Pricebook p on p.Id = pe.PricebookId
	join PlanOrderToCashCycle potc on potc.PricebookId = p.Id
	join @PlanProductIds ppi ON ppi.Id = potc.PlanProductId

	SELECT stc.*
		, stc.TypeId as [Type]
		, stc.StatusId as [Status]
	FROM SalesTrackingCode stc
	join PricebookEntry pe on pe.SalesTrackingCode1Id = stc.Id 
		or pe.SalesTrackingCode2Id = stc.Id
		or pe.SalesTrackingCode3Id = stc.Id
		or pe.SalesTrackingCode4Id = stc.Id
		or pe.SalesTrackingCode5Id = stc.Id
	join Pricebook p on p.Id = pe.PricebookId
	join PlanOrderToCashCycle potc on potc.PricebookId = p.Id
	join @PlanProductIds ppi ON ppi.Id = potc.PlanProductId
END

GO

