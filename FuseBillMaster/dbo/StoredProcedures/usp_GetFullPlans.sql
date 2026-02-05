
CREATE   PROCEDURE [dbo].[usp_GetFullPlans]  
	@accountId as bigint,
	@planIds AS dbo.IDList READONLY
AS  
BEGIN  
-- SET NOCOUNT ON added to prevent extra result sets from  
-- interfering with SELECT statements.  
SET NOCOUNT ON;  
  
DECLARE @plans TABLE (Id bigint)  

INSERT INTO @plans SELECT p.Id FROM [plan] p join @planIds pp on p.Id = pp.Id and p.AccountId = @accountId
WHERE p.IsDeleted = 0

DECLARE @OrderToCashCycleIds TABLE (Id bigint)
DECLARE @QuantityRangeIds TABLE (Id bigint)

INSERT INTO @OrderToCashCycleIds SELECT pocc.Id
	FROM [dbo].[PlanOrderToCashCycle] pocc
	INNER JOIN [dbo].[OrderToCashCycle] occ ON occ.Id = pocc.Id
	INNER JOIN PlanProduct pp ON pp.Id = pocc.PlanProductId
	INNER JOIN PlanRevision pr ON pr.Id = pp.PlanRevisionId
	INNER JOIN @plans plans ON pr.PlanId = plans.Id

INSERT INTO @OrderToCashCycleIds SELECT pe.OrderToCashCycleId 
	FROM Pricebook pb
	INNER JOIN PricebookEntry pe ON pb.Id = pe.PricebookId

INSERT INTO @QuantityRangeIds SELECT qr.Id FROM QuantityRange qr
	INNER JOIN @OrderToCashCycleIds o2ci ON o2ci.Id = qr.OrderToCashCycleId

SELECT p.*, p.StatusId as [Status]  
FROM [Plan] p  
INNER JOIN @plans plans ON p.Id = plans.Id  
  
SELECT * FROM PlanRevision pr  
INNER JOIN @plans plans ON pr.PlanId = plans.Id AND pr.IsActive = 1  
  
SELECT pf.*, StatusId as [Status]  
FROM PlanFrequency pf  
INNER JOIN PlanRevision pr ON pr.Id = pf.PlanRevisionId  
INNER JOIN @plans plans ON pr.PlanId = plans.Id  
  
SELECT pfk.[Id], pfk.[CreatedTimestamp]  
FROM [dbo].[PlanFrequencyKey] pfk  
INNER JOIN [dbo].[PlanFrequency] pf ON pfk.Id = pf.PlanFrequencyUniqueId  
INNER JOIN [dbo].[PlanRevision] pr ON pr.Id = pf.PlanRevisionId  
INNER JOIN @plans plans ON pr.PlanId = plans.Id  
  
SELECT pp.*, pp.[ResetTypeId] as ResetType, pp.[StatusId] as Status  
FROM [dbo].[PlanProduct] pp  
INNER JOIN PlanRevision pr ON pr.Id = pp.PlanRevisionId  
INNER JOIN @plans plans ON pr.PlanId = plans.Id  
  
SELECT p.*, p.[ProductTypeId] as ProductType, p.[ProductStatusId] as Status  
FROM [dbo].[Product] p  
INNER JOIN PlanProduct pp ON p.Id = pp.ProductId  
INNER JOIN PlanRevision pr ON pr.Id = pp.PlanRevisionId  
INNER JOIN @plans plans ON pr.PlanId = plans.Id  
  
SELECT gl.*, gl.[StatusId] as Status  
FROM [dbo].[GLCode] gl  
WHERE gl.AccountId = @accountId
  
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
  
SELECT pfcf.*  
FROM [dbo].[PlanFrequencyCustomField] pfcf  
INNER JOIN [dbo].[PlanFrequency] pf ON pf.PlanFrequencyUniqueId = pfcf.PlanFrequencyUniqueId  
INNER JOIN [dbo].[PlanRevision] pr ON pr.Id = pf.PlanRevisionId  
INNER JOIN @plans plans ON pr.PlanId = plans.Id  
  
SELECT cf.*, cf.[DataTypeId] as [DataType], cf.[StatusId] as [Status]  
FROM [dbo].[CustomField] cf  
INNER JOIN [dbo].[PlanFrequencyCustomField] pfcf ON cf.Id = pfcf.CustomFieldId  
INNER JOIN [dbo].[PlanFrequency] pf ON pf.PlanFrequencyUniqueId = pfcf.PlanFrequencyUniqueId  
INNER JOIN [dbo].[PlanRevision] pr ON pr.Id = pf.PlanRevisionId  
INNER JOIN @plans plans ON pr.PlanId = plans.Id  
UNION ALL  
SELECT cf.*, cf.[DataTypeId] as [DataType], cf.[StatusId] as [Status]  
FROM [dbo].[CustomField] cf  
INNER JOIN [dbo].[PlanProductFrequencyCustomField] ppfcf ON cf.Id = ppfcf.CustomFieldId  
INNER JOIN PlanProduct pp ON pp.PlanProductUniqueId = ppfcf.PlanProductUniqueId  
INNER JOIN [dbo].[PlanRevision] pr ON pr.Id = pp.PlanRevisionId  
INNER JOIN @plans plans ON pr.PlanId = plans.Id  
  
SELECT ppk.[Id], ppk.[CreatedTimestamp]  
FROM [dbo].[PlanProductKey] ppk  
INNER JOIN PlanProduct pp ON ppk.Id = pp.PlanProductUniqueId  
INNER JOIN [dbo].[PlanRevision] pr ON pr.Id = pp.PlanRevisionId  
INNER JOIN @plans plans ON pr.PlanId = plans.Id  
  
SELECT ppfcf.*  
FROM [dbo].[PlanProductFrequencyCustomField] ppfcf  
INNER JOIN PlanProduct pp ON pp.PlanProductUniqueId = ppfcf.PlanProductUniqueId  
INNER JOIN [dbo].[PlanRevision] pr ON pr.Id = pp.PlanRevisionId  
INNER JOIN @plans plans ON pr.PlanId = plans.Id  
  
SELECT pu.*  
FROM [dbo].PlanProductPriceUplift pu  
INNER JOIN [dbo].[PlanOrderToCashCycle] pocc on pocc.Id = pu.PlanOrderToCashCycleId  
INNER JOIN PlanProduct pp ON pp.Id = pocc.PlanProductId  
INNER JOIN [dbo].[PlanRevision] pr ON pr.Id = pp.PlanRevisionId  
INNER JOIN @plans plans ON pr.PlanId = plans.Id  
  
SELECT pfcc.*
FROM [dbo].[PlanFrequencyCouponCode] pfcc
INNER JOIN [dbo].[PlanFrequency] pf ON pf.PlanFrequencyUniqueId = pfcc.PlanFrequencyUniqueId  
INNER JOIN [dbo].[PlanRevision] pr ON pr.Id = pf.PlanRevisionId  
INNER JOIN @plans plans ON pr.PlanId = plans.Id  

SELECT cc.* 
	FROM CouponCode cc
	INNER JOIN [PlanFrequencyCouponCode] pfcc ON cc.Id = pfcc.CouponCodeId
	INNER JOIN [dbo].[PlanFrequency] pf ON pf.PlanFrequencyUniqueId = pfcc.PlanFrequencyUniqueId  
	INNER JOIN [dbo].[PlanRevision] pr ON pr.Id = pf.PlanRevisionId
	INNER JOIN @plans plans ON pr.PlanId = plans.Id

	SELECT c.*, c.StatusId as [Status]
	FROM Coupon c
	INNER JOIN CouponCode cc ON c.Id = cc.CouponId
	INNER JOIN [PlanFrequencyCouponCode] pfcc ON cc.Id = pfcc.CouponCodeId
	INNER JOIN [dbo].[PlanFrequency] pf ON pf.PlanFrequencyUniqueId = pfcc.PlanFrequencyUniqueId  
	INNER JOIN [dbo].[PlanRevision] pr ON pr.Id = pf.PlanRevisionId
	INNER JOIN @plans plans ON pr.PlanId = plans.Id
  
END

GO

