

CREATE   PROCEDURE [dbo].[Staffside_CouponUsage]
	@AccountId BIGINT
	,@StartDate DATETIME
	,@EndDate DATETIME
AS


WITH purchase_cte AS(
	SELECT
	p.CustomerId,
	p.Id AS PurchaseId,
	pcc.CreatedTimestamp AS CouponApplicationTimestamp,
	p.StatusId AS PurchaseStatusId,
	p.IsDeleted AS PurchaseIsDeleted,
	pcc.CouponCodeId,
	cc.Code AS CouponCode
	FROM PurchaseCouponCode pcc
	INNER JOIN CouponCode cc ON cc.Id = pcc.CouponCodeId
	INNER JOIN Purchase p ON p.Id = pcc.PurchaseId
	INNER JOIN customer c ON c.Id = p.CustomerId
	WHERE c.AccountId = @AccountID
	AND pcc.CreatedTimestamp >= @StartDate AND pcc.CreatedTimestamp < @EndDate
), subscription_cte AS (
	SELECT
	s.CustomerId,
	s.Id AS SubscriptionId,
	scc.CreatedTimestamp AS CouponApplicationTimestamp,
	s.StatusId AS SubscriptionStatusId,
	s.IsDeleted AS SubscriptionIsDeleted,
	scc.CouponCodeId,
	cc.Code AS CouponCode
	FROM SubscriptionCouponCode scc
	INNER JOIN CouponCode cc ON cc.Id = scc.CouponCodeId
	INNER JOIN Subscription s ON s.Id = scc.SubscriptionId
	INNER JOIN customer c ON c.Id = s.CustomerId
	WHERE c.AccountId = @AccountID
	AND scc.CreatedTimestamp >= @StartDate AND scc.CreatedTimestamp < @EndDate
)
SELECT
CustomerId AS [Stax Bill ID],
CouponCodeId AS [Coupon Code ID],
CouponCode AS [Coupon Code],
CouponApplicationTimestamp AS [Application Timestamp UTC],
NULL AS [Subscription ID],
NULL AS [Subscription Status],
NULL AS [Subscription Is Soft Deleted],
purchaseId AS [Purchase ID],
ps.[Name] AS [Purchase Status],
CASE WHEN PurchaseIsDeleted = 1 THEN 'true' ELSE 'false' END AS [Purchase Is Soft Deleted]
FROM purchase_cte
LEFT JOIN lookup.PurchaseStatus ps ON ps.Id = purchase_cte.PurchaseStatusId


UNION


SELECT
CustomerId AS [Stax Bill ID],
CouponCodeId AS [Coupon Code ID],
CouponCode AS [Coupon Code],
CouponApplicationTimestamp AS [Application Timestamp UTC],
SubscriptionId AS [Subscription ID],
ss.[Name] AS [Subscription Status],
CASE WHEN SubscriptionIsDeleted = 1 THEN 'true' ELSE 'false' END AS [Subscription Is Soft Deleted],
NULL AS [Purchase ID],
NULL AS [Purchase Status],
NULL AS [Purchase Is Soft Deleted]
FROM subscription_cte
LEFT JOIN lookup.SubscriptionStatus ss ON ss.Id = subscription_cte.SubscriptionStatusId

GO

