CREATE PROCEDURE [dbo].[usp_GetPlanProductsAndFullOrderToCashCycle]
	@PlanRevisionId BIGINT,
	@PlanFrequencyId BIGINT = null ,
	@ExcludeDeletedProducts bit = 1
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @PlanFrequencyIds TABLE (Id bigint)
    DECLARE @PlanProductIds TABLE (Id bigint)
	DECLARE @OrderToCashCycleIds TABLE (Id bigint)
	DECLARE @QuantityRangeIds TABLE (Id bigint)

	IF @PlanFrequencyId IS NOT NULL
	BEGIN
		INSERT INTO @PlanFrequencyIds SELECT Id FROM PlanFrequency WHERE PlanRevisionId = @PlanRevisionId AND Id = @PlanFrequencyId
	END
	ELSE
	BEGIN
		INSERT INTO @PlanFrequencyIds SELECT Id FROM PlanFrequency WHERE PlanRevisionId = @PlanRevisionId
	END

	INSERT INTO @PlanProductIds SELECT Id FROM PlanProduct WHERE PlanRevisionId = @PlanRevisionId

	INSERT INTO @OrderToCashCycleIds SELECT o2c.Id FROM PlanOrderToCashCycle o2c
		INNER JOIN @PlanProductIds ppi ON o2c.PlanProductId = ppi.Id
		INNER JOIN @PlanFrequencyIds pfi ON o2c.PlanFrequencyId = pfi.Id

	INSERT INTO @OrderToCashCycleIds SELECT pe.OrderToCashCycleId FROM @OrderToCashCycleIds o2c
		INNER JOIN PlanOrderToCashCycle potc ON potc.Id = o2c.Id
		INNER JOIN Pricebook pb ON potc.PricebookId = pb.Id
		INNER JOIN PricebookEntry pe ON pb.Id = pe.PricebookId

	INSERT INTO @QuantityRangeIds SELECT qr.Id FROM QuantityRange qr
		INNER JOIN @OrderToCashCycleIds o2ci ON o2ci.Id = qr.OrderToCashCycleId

	SELECT 
		pf.*,
		pf.StatusId as [Status]
	FROM PlanFrequency pf
	INNER JOIN @PlanFrequencyIds pfi ON pf.Id = pfi.Id

	SELECT pfk.*
	FROM PlanFrequencyKey pfk
	INNER JOIN PlanFrequency pf ON pf.PlanFrequencyUniqueId = pfk.id
	INNER JOIN @PlanFrequencyIds pfi ON pf.Id = pfi.Id

	SELECT 
		pp.*,
		pp.ResetTypeId as ResetType,
		pp.StatusId as [Status]
	FROM PlanProduct pp
	INNER JOIN @PlanProductIds ppi ON pp.Id = ppi.Id
	WHERE pp.StatusId != case when @ExcludeDeletedProducts = 1 THEN 4 ELSE 0 END --deleted

	SELECT ppk.*
	FROM PlanProductKey ppk
	INNER JOIN PlanProduct pp ON ppk.Id = pp.PlanProductUniqueId
	INNER JOIN @PlanProductIds ppi ON ppi.Id = pp.Id

	SELECT
		p.*,
		p.ProductTypeId as ProductType,
		p.ProductStatusId as Status
	FROM PlanProduct pp
	INNER JOIN @PlanProductIds ppi ON pp.Id = ppi.Id
	INNER JOIN Product p ON p.Id = pp.ProductId

	SELECT *
	FROM Pricebook pb
	INNER JOIN PricebookEntry pe ON pb.Id = pe.PricebookId
	INNER JOIN OrderToCashCycle otc ON otc.Id = pe.OrderToCashCycleId
	INNER JOIN @OrderToCashCycleIds otc2 ON otc.Id = otc2.Id

	SELECT *
	FROM PricebookEntry pe
	INNER JOIN OrderToCashCycle otc ON otc.Id = pe.OrderToCashCycleId
	INNER JOIN @OrderToCashCycleIds otc2 ON otc.Id = otc2.Id

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
	INNER JOIN @OrderToCashCycleIds o2ci ON o2c.Id = o2ci.Id
	INNER JOIN PlanOrderToCashCycle potc ON potc.Id = o2c.Id

	SELECT
		o2c.*,
		o2c.PricingModelTypeId as PricingModelType,
		o2c.EarningTimingIntervalId as EarningTimingInterval,
		o2c.EarningTimingTypeId as EarningTimingType
	FROM OrderToCashCycle o2c
	INNER JOIN @OrderToCashCycleIds o2ci ON o2c.Id = o2ci.Id
	LEFT JOIN PlanOrderToCashCycle potc ON potc.Id = o2c.Id
	WHERE potc.Id IS NULL

	SELECT 
		*
	FROM QuantityRange qr
	INNER JOIN @OrderToCashCycleIds o2ci ON o2ci.Id = qr.OrderToCashCycleId

	SELECT 
		*
	FROM Price p
	INNER JOIN @QuantityRangeIds qr ON qr.Id = p.QuantityRangeId

	SELECT 
		*
	FROM PlanProductPriceUplift pu
	INNER JOIN @OrderToCashCycleIds o2ci ON o2ci.Id = pu.PlanOrderToCashCycleId
  
	SELECT pfcc.*
	FROM [dbo].[PlanFrequencyCouponCode] pfcc
	INNER JOIN [dbo].[PlanFrequency] pf ON pf.PlanFrequencyUniqueId = pfcc.PlanFrequencyUniqueId  
	INNER JOIN @PlanFrequencyIds pfi ON pf.Id = pfi.Id

	SELECT cc.* 
	FROM CouponCode cc
	INNER JOIN [PlanFrequencyCouponCode] pfcc ON cc.Id = pfcc.CouponCodeId
	INNER JOIN [dbo].[PlanFrequency] pf ON pf.PlanFrequencyUniqueId = pfcc.PlanFrequencyUniqueId  
	INNER JOIN @PlanFrequencyIds pfi ON pf.Id = pfi.Id

	SELECT c.*, c.StatusId as [Status]
	FROM Coupon c
	INNER JOIN CouponCode cc ON c.Id = cc.CouponId
	INNER JOIN [PlanFrequencyCouponCode] pfcc ON cc.Id = pfcc.CouponCodeId
	INNER JOIN [dbo].[PlanFrequency] pf ON pf.PlanFrequencyUniqueId = pfcc.PlanFrequencyUniqueId  
	INNER JOIN @PlanFrequencyIds pfi ON pf.Id = pfi.Id

	END

GO

