CREATE PROCEDURE usp_GetProductItemsByInvoiceId
	@InvoiceId bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select 
		[pi].*
		,[pi].StatusId as [Status]
	from ProductItem [pi]
	join ChargeProductItem cpi on cpi.ProductItemId = [pi].Id
	join Charge c on c.Id = cpi.ChargeId
	where c.InvoiceId = @InvoiceId

	select cpi.*
	from ChargeProductItem cpi
	join Charge c on c.Id = cpi.ChargeId
	where c.InvoiceId = @InvoiceId

	select 
		spi.*
	from SubscriptionProductItem spi
	join SubscriptionProduct sp on sp.Id = spi.SubscriptionProductId
	join SubscriptionProductCharge spc on spc.SubscriptionProductId = sp.Id
	join Charge c on c.Id = spc.Id
	where c.InvoiceId = @InvoiceId


	select 
		sp.*
		,sp.StatusId as [Status]
		,sp.EarningTimingTypeId as [EarningTimingType]
		,sp.EarningTimingIntervalId as [EarningTimingInterval]
		,sp.ResetTypeId as [ResetType]
		,sp.RecurChargeTimingTypeId as RecurChargeTimingType
		,sp.PricingFormulaTypeId as PricingFormulaType
		,sp.PricingModelTypeId as PricingModelType
		,sp.ProductTypeId as ProductType
		,sp.QuantityChargeTimingTypeId as QuantityChargeTimingType
		,sp.RecurProrateGranularityId as RecurProrateGranularity
		,sp.QuantityProrateGranularityId as QuantityProrateGranularity
		,sp.EarningIntervalId as EarningInterval
		,sp.CustomServiceDateIntervalId as CustomServiceDateInterval
		,sp.CustomServiceDateProjectionId as CustomServiceDateProjection
	from SubscriptionProduct sp 
	join SubscriptionProductCharge spc on spc.SubscriptionProductId = sp.Id
	join Charge c on c.Id = spc.Id
	where c.InvoiceId = @InvoiceId

	select 
		p.*
		,p.StatusId as [Status]
		,p.PricingFormulaTypeId as PricingFormulaType
		,p.PricingModelTypeId as PricingModelType
		,p.EarningTimingTypeId as [EarningTimingType]
		,p.EarningTimingIntervalId as [EarningTimingInterval]
	from Purchase p
	join PurchaseCharge pc on pc.PurchaseId = p.Id
	join Charge c on c.Id = pc.Id
	where c.InvoiceId = @InvoiceId

END

GO

