CREATE PROCEDURE [dbo].[usp_GetFullPlanProducts]
	@Ids nvarchar(max),
	@AccountId bigint = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

declare @planProducts table
(
PlanProductId bigint
)

INSERT INTO @planProducts (PlanProductId)
select Data from dbo.Split (@Ids,'|')

DECLARE @OrderToCashCycleIds TABLE (Id bigint)
DECLARE @QuantityRangeIds TABLE (Id bigint)

INSERT INTO @OrderToCashCycleIds SELECT pocc.Id
	FROM [dbo].[PlanOrderToCashCycle] pocc
	INNER JOIN [dbo].[OrderToCashCycle] occ ON occ.Id = pocc.Id
	INNER JOIN @planProducts pp ON pocc.PlanProductId = pp.PlanProductId

INSERT INTO @OrderToCashCycleIds SELECT pe.OrderToCashCycleId 
	FROM Pricebook pb
	INNER JOIN PricebookEntry pe ON pb.Id = pe.PricebookId

INSERT INTO @QuantityRangeIds SELECT qr.Id FROM QuantityRange qr
	INNER JOIN @OrderToCashCycleIds o2ci ON o2ci.Id = qr.OrderToCashCycleId

SELECT pp.*
      ,pp.[ResetTypeId] as ResetType
      ,pp.[StatusId] as Status
  FROM [dbo].[PlanProduct] pp
INNER JOIN @planProducts ppIds on pp.Id = ppIds.PlanProductId
INNER JOIN Product p ON p.Id = pp.ProductId
WHERE ISNULL(@AccountId, p.AccountId) = p.AccountId

SELECT p.*
      ,p.[ProductTypeId] as ProductType
      ,p.[ProductStatusId] as Status
  FROM [dbo].[Product] p
  INNER JOIN PlanProduct pp ON p.Id = pp.ProductId
  INNER JOIN @planProducts ppIds on pp.Id = ppIds.PlanProductId
  WHERE ISNULL(@AccountId, p.AccountId) = p.AccountId

SELECT gl.*
      ,gl.[StatusId] as Status
  FROM [dbo].[GLCode] gl
WHERE gl.AccountId = @AccountId

SELECT pr.*
  FROM [dbo].[PlanRevision] pr
   INNER JOIN PlanProduct pp ON pr.Id = pp.PlanRevisionId
  INNER JOIN @planProducts ppIds on pp.Id = ppIds.PlanProductId
  INNER JOIN [dbo].[Product] p ON p.Id = pp.ProductId
  WHERE ISNULL(@AccountId, p.AccountId) = p.AccountId

SELECT pl.*
      ,pl.[StatusId] as Status
  FROM [dbo].[Plan] pl
  INNER JOIN [dbo].[PlanRevision] pr ON pl.Id = pr.PlanId
   INNER JOIN PlanProduct pp ON pr.Id = pp.PlanRevisionId
  INNER JOIN @planProducts ppIds on pp.Id = ppIds.PlanProductId
  INNER JOIN [dbo].[Product] p ON p.Id = pp.ProductId
  WHERE ISNULL(@AccountId, p.AccountId) = p.AccountId

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

SELECT pf.*
      ,pf.[Interval]
      ,pf.[StatusId] as [Status]
  FROM [dbo].[PlanFrequency] pf
INNER JOIN [dbo].[PlanRevision] pr ON pr.Id = pf.PlanRevisionId
   INNER JOIN PlanProduct pp ON pr.Id = pp.PlanRevisionId
  INNER JOIN @planProducts ppIds on pp.Id = ppIds.PlanProductId
  INNER JOIN [dbo].[Product] p ON p.Id = pp.ProductId
  WHERE ISNULL(@AccountId, p.AccountId) = p.AccountId

SELECT pfk.[Id]
      ,pfk.[CreatedTimestamp]
  FROM [dbo].[PlanFrequencyKey] pfk
  INNER JOIN [dbo].[PlanFrequency] pf ON pfk.Id = pf.PlanFrequencyUniqueId
INNER JOIN [dbo].[PlanRevision] pr ON pr.Id = pf.PlanRevisionId
   INNER JOIN PlanProduct pp ON pr.Id = pp.PlanRevisionId
  INNER JOIN @planProducts ppIds on pp.Id = ppIds.PlanProductId
  INNER JOIN [dbo].[Product] p ON p.Id = pp.ProductId
  WHERE ISNULL(@AccountId, p.AccountId) = p.AccountId

SELECT pfcf.*
  FROM [dbo].[PlanFrequencyCustomField] pfcf
  INNER JOIN [dbo].[PlanFrequency] pf ON pf.PlanFrequencyUniqueId = pfcf.PlanFrequencyUniqueId
INNER JOIN [dbo].[PlanRevision] pr ON pr.Id = pf.PlanRevisionId
   INNER JOIN PlanProduct pp ON pr.Id = pp.PlanRevisionId
  INNER JOIN @planProducts ppIds on pp.Id = ppIds.PlanProductId
  INNER JOIN [dbo].[Product] p ON p.Id = pp.ProductId
  WHERE ISNULL(@AccountId, p.AccountId) = p.AccountId

SELECT cf.*
      ,cf.[DataTypeId] as [DataType]
      ,cf.[StatusId] as [Status]
  FROM [dbo].[CustomField] cf
  INNER JOIN [dbo].[PlanFrequencyCustomField] pfcf ON cf.Id = pfcf.CustomFieldId
  INNER JOIN [dbo].[PlanFrequency] pf ON pf.PlanFrequencyUniqueId = pfcf.PlanFrequencyUniqueId
INNER JOIN [dbo].[PlanRevision] pr ON pr.Id = pf.PlanRevisionId
   INNER JOIN PlanProduct pp ON pr.Id = pp.PlanRevisionId
  INNER JOIN @planProducts ppIds on pp.Id = ppIds.PlanProductId
  INNER JOIN [dbo].[Product] p ON p.Id = pp.ProductId
  WHERE ISNULL(@AccountId, p.AccountId) = p.AccountId
UNION ALL
SELECT cf.*
      ,cf.[DataTypeId] as [DataType]
      ,cf.[StatusId] as [Status]
  FROM [dbo].[CustomField] cf
  INNER JOIN [dbo].[PlanProductFrequencyCustomField] ppfcf ON cf.Id = ppfcf.CustomFieldId
  INNER JOIN PlanProduct pp ON pp.PlanProductUniqueId = ppfcf.PlanProductUniqueId
  INNER JOIN @planProducts ppIds on pp.Id = ppIds.PlanProductId
  INNER JOIN [dbo].[Product] p ON p.Id = pp.ProductId
  WHERE ISNULL(@AccountId, p.AccountId) = p.AccountId

SELECT ppk.[Id]
      ,ppk.[CreatedTimestamp]
  FROM [dbo].[PlanProductKey] ppk
  INNER JOIN PlanProduct pp ON ppk.Id = pp.PlanProductUniqueId
  INNER JOIN @planProducts ppIds on pp.Id = ppIds.PlanProductId
  INNER JOIN [dbo].[Product] p ON p.Id = pp.ProductId
  WHERE ISNULL(@AccountId, p.AccountId) = p.AccountId

SELECT ppfcf.*
  FROM [dbo].[PlanProductFrequencyCustomField] ppfcf
  INNER JOIN PlanProduct pp ON pp.PlanProductUniqueId = ppfcf.PlanProductUniqueId
  INNER JOIN @planProducts ppIds on pp.Id = ppIds.PlanProductId
  INNER JOIN [dbo].[Product] p ON p.Id = pp.ProductId
  WHERE ISNULL(@AccountId, p.AccountId) = p.AccountId

  SELECT pu.*
  FROM [dbo].PlanProductPriceUplift pu
	INNER JOIN [dbo].[PlanOrderToCashCycle] pocc on pocc.Id = pu.PlanOrderToCashCycleId
  INNER JOIN PlanProduct pp ON pp.Id = pocc.PlanProductId
  INNER JOIN @planProducts ppIds on pp.Id = ppIds.PlanProductId
  INNER JOIN [dbo].[Product] p ON p.Id = pp.ProductId
  WHERE ISNULL(@AccountId, p.AccountId) = p.AccountId

SELECT pfcc.*
  FROM [dbo].[PlanFrequencyCouponCode] pfcc
  INNER JOIN [dbo].[PlanFrequency] pf ON pf.PlanFrequencyUniqueId = pfcc.PlanFrequencyUniqueId
INNER JOIN [dbo].[PlanRevision] pr ON pr.Id = pf.PlanRevisionId
   INNER JOIN PlanProduct pp ON pr.Id = pp.PlanRevisionId
  INNER JOIN @planProducts ppIds on pp.Id = ppIds.PlanProductId
  INNER JOIN [dbo].[Product] p ON p.Id = pp.ProductId
  WHERE ISNULL(@AccountId, p.AccountId) = p.AccountId


SELECT cc.* 
	FROM CouponCode cc
	INNER JOIN [PlanFrequencyCouponCode] pfcc ON cc.Id = pfcc.CouponCodeId
	INNER JOIN [dbo].[PlanFrequency] pf ON pf.PlanFrequencyUniqueId = pfcc.PlanFrequencyUniqueId  
	INNER JOIN [dbo].[PlanRevision] pr ON pr.Id = pf.PlanRevisionId
	INNER JOIN PlanProduct pp ON pr.Id = pp.PlanRevisionId
  INNER JOIN @planProducts ppIds on pp.Id = ppIds.PlanProductId
  INNER JOIN [dbo].[Product] p ON p.Id = pp.ProductId
  WHERE ISNULL(@AccountId, p.AccountId) = p.AccountId

	SELECT c.*, c.StatusId as [Status]
	FROM Coupon c
	INNER JOIN CouponCode cc ON c.Id = cc.CouponId
	INNER JOIN [PlanFrequencyCouponCode] pfcc ON cc.Id = pfcc.CouponCodeId
	INNER JOIN [dbo].[PlanFrequency] pf ON pf.PlanFrequencyUniqueId = pfcc.PlanFrequencyUniqueId  
	INNER JOIN [dbo].[PlanRevision] pr ON pr.Id = pf.PlanRevisionId
	INNER JOIN PlanProduct pp ON pr.Id = pp.PlanRevisionId
  INNER JOIN @planProducts ppIds on pp.Id = ppIds.PlanProductId
  INNER JOIN [dbo].[Product] p ON p.Id = pp.ProductId
  WHERE ISNULL(@AccountId, p.AccountId) = p.AccountId

  END

GO

