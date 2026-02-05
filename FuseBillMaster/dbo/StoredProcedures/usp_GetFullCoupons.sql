
CREATE   PROCEDURE [dbo].[usp_GetFullCoupons]
	@couponIds nvarchar(max),
	@accountId bigint,
	@includeAllCouponPlanProducts bit
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

declare @coupons table
(
CouponId bigint
)

INSERT INTO @coupons (CouponId)
select Data from dbo.Split (@couponIds,'|') as coupons
	inner join Coupon cu on cu.Id = coupons.Data
	where cu.AccountId =
		CASE WHEN @accountId = 0 THEN
		 cu.AccountId
		ELSE
		 @accountId
		End

SELECT c.*
	, StatusId as [Status]
FROM [dbo].[Coupon] c
INNER JOIN @coupons ccc ON c.Id = ccc.CouponId

SELECT cc.* FROM [dbo].[CouponCode] cc
INNER JOIN @coupons ccc ON cc.CouponId = ccc.CouponId

SELECT cd.* FROM [dbo].[CouponDiscount] cd
INNER JOIN @coupons ccc ON cd.CouponId = ccc.CouponId

SELECT dc.Id
	, dc.AccountId
	, dc.RemainingUsagesUntilStart
	, dc.RemainingUsage
	, dc.Amount
	, dc.DiscountTypeId as DiscountType
	, dc.Name
	, dc.[Description]
	, dc.Code
	, StatusId as [Status]
	, NetsuiteItemId
FROM [dbo].[DiscountConfiguration] dc
INNER JOIN [dbo].[CouponDiscount] cd ON dc.Id = cd.DiscountConfigurationId
INNER JOIN @coupons ccc ON cd.CouponId = ccc.CouponId

SELECT dcf.*
FROM [dbo].[DiscountConfigurationFrequency] dcf
INNER JOIN [dbo].[DiscountConfiguration] dc ON dc.Id = dcf.DiscountConfigurationId
INNER JOIN [dbo].[CouponDiscount] cd ON dc.Id = cd.DiscountConfigurationId
INNER JOIN @coupons ccc ON cd.CouponId = ccc.CouponId

SELECT ce.* FROM [dbo].[CouponEligibility] ce
INNER JOIN [dbo].[CouponDiscount] cd ON ce.Id = cd.CouponEligibilityId
INNER JOIN @coupons ccc ON cd.CouponId = ccc.CouponId

SELECT cp.* FROM [dbo].[CouponPlan] cp
INNER JOIN dbo.[plan] p on p.Id = cp.PlanId
INNER JOIN @coupons ccc ON cp.CouponId = ccc.CouponId
WHERE p.IsDeleted = 0

SELECT p.*, p.[StatusId] as Status
FROM [dbo].[Plan] p
INNER JOIN [dbo].[CouponPlan] cp ON p.Id = cp.PlanId 
WHERE @includeAllCouponPlanProducts = 1
AND p.IsDeleted = 0

SELECT cpp.* FROM [dbo].[CouponPlanProduct] cpp
INNER JOIN [PlanProduct] pp ON pp.PlanProductUniqueId = cpp.PlanProductKey AND (pp.StatusId = 1 OR @includeAllCouponPlanProducts = 1)
INNER JOIN [dbo].[CouponPlan] cp ON cp.Id = cpp.CouponPlanId
INNER JOIN @coupons ccc ON cp.CouponId = ccc.CouponId

SELECT ppk.* FROM [dbo].[PlanProductKey] ppk
inner join [CouponPlanProduct] cpp on cpp.PlanProductKey = ppk.Id
INNER JOIN [dbo].[CouponPlan] cp ON cp.Id = cpp.CouponPlanId
INNER JOIN @coupons ccc ON cp.CouponId = ccc.CouponId

;WITH CTE_PlanProducts AS (
	SELECT 
	ROW_NUMBER() OVER (PARTITION BY pp.[PlanProductUniqueId] ORDER BY pp.[Id] DESC) AS [RowNumber],
	pp.*,
	pp.ResetTypeId as [ResetType],
	pp.[StatusId] as [Status]
	FROM [PlanProduct] pp 
	inner join [PlanProductKey] ppk on ppk.[Id] = pp.[PlanProductUniqueId]
	inner join [CouponPlanProduct] cpp on cpp.PlanProductKey = ppk.Id
	INNER JOIN [dbo].[CouponPlan] cp ON cp.Id = cpp.CouponPlanId
	INNER JOIN @coupons ccc ON cp.CouponId = ccc.CouponId
)
Select * from CTE_PlanProducts where [RowNumber] = 1 

END

GO

