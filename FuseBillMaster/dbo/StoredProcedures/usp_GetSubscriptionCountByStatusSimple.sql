CREATE procedure [dbo].[usp_GetSubscriptionCountByStatusSimple]
	@AccountId bigint
	, @Currency bigint = NULL
	, @SalesTrackingCode1Id BIGINT = null
	, @SalesTrackingCode2Id BIGINT = null 
	, @SalesTrackingCode3Id BIGINT = null
	, @SalesTrackingCode4Id BIGINT = null 
	, @SalesTrackingCode5Id BIGINT = null
as

SELECT
	s.PlanId as Id
	,@AccountId as AccountId
	,s.PlanName as [Name]
	,s.PlanCode as [Code]
	,ss.Name as [Status]
	,ss.SortOrder as SortOrder
	,COUNT(DISTINCT s.Id) as [Count]
	,SUM(Count(DISTINCT s.Id)) OVER (PARTITION BY s.PlanId) as Total
FROM Subscription s
INNER JOIN Customer c ON c.Id = s.CustomerId
INNER JOIN CustomerReference cr ON cr.Id = c.Id
INNER JOIN Lookup.SubscriptionStatus ss ON ss.Id = s.StatusId
WHERE c.AccountId = @AccountId
	AND c.CurrencyId = ISNULL(@Currency, c.CurrencyId) 
	AND (@SalesTrackingCode1Id IS NULL OR @SalesTrackingCode1Id = cr.SalesTrackingCode1Id)
	AND (@SalesTrackingCode2Id IS NULL OR @SalesTrackingCode2Id = cr.SalesTrackingCode2Id)
	AND (@SalesTrackingCode3Id IS NULL OR @SalesTrackingCode3Id = cr.SalesTrackingCode3Id)
	AND (@SalesTrackingCode4Id IS NULL OR @SalesTrackingCode4Id = cr.SalesTrackingCode4Id)
	AND (@SalesTrackingCode5Id IS NULL OR @SalesTrackingCode5Id = cr.SalesTrackingCode5Id)
GROUP BY
	s.PlanId
	,s.PlanName
	,s.PlanCode
	,ss.Name
	,ss.SortOrder

GO

