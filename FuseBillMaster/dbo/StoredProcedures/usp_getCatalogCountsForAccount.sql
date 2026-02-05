
CREATE     PROCEDURE [dbo].[usp_getCatalogCountsForAccount]
       @AccountId BIGINT
AS

SELECT COUNT(Id) AS [PlanFamilyCount]
FROM dbo.PlanFamily  pf
WHERE pf.AccountId = @AccountId

SELECT COUNT(Id) AS [PlanCount]
FROM dbo.[Plan]  p
WHERE p.AccountId = @AccountId
AND p.IsDeleted = 0

SELECT COUNT(Id) AS [ProductCount]
FROM dbo.[Product]  p
WHERE p.AccountId = @AccountId
AND p.ProductTypeId IN (1,2,3) --PhysicalGood, Recurring service, One-time charge

SELECT COUNT(Id) AS [DiscountCount]
FROM dbo.[DiscountConfiguration]  dc
WHERE dc.AccountId = @AccountId

SELECT COUNT(Id) AS [CouponCount]
FROM dbo.Coupon c
WHERE c.AccountId = @AccountId

SELECT COUNT(Id) AS [GLCodeCount]
FROM dbo.GLCode g
WHERE g.AccountId = @AccountId

SELECT COUNT(Id) AS [PriceBookCount]
FROM dbo.PriceBook pb
WHERE pb.AccountId = @AccountId

GO

