
CREATE   PROCEDURE [dbo].[usp_GetSubscriptionProductIncludeExport]  
 @accountId BIGINT,  
 @planProductIds AS dbo.IDList READONLY,
 @productIds AS dbo.IDList READONLY,
 @planFrequencyId BIGINT,  
 @allPlanProducts bit,
 @customerId BIGINT = NULL
AS  
BEGIN  
	 -- SET NOCOUNT ON added to prevent extra result sets from  
	 -- interfering with SELECT statements.  
	SET NOCOUNT ON;  
  
	SELECT   
		c.Id AS [FusebillId]  
		, c.Reference AS [CustomerId]  
		, c.FirstName AS [CustomerFirstName]  
		, c.LastName AS [CustomerLastName]  
		, c.CompanyName AS [CustomerCompanyName]  
		, p.Code AS [PlanCode]  
		, s.Id AS [SubscriptionId]  
		, CASE WHEN so.Id IS NULL AND so.Name IS NULL THEN s.PlanName ELSE so.Name END as [SubscriptionName]  
		, CASE WHEN so.Id IS NULL AND so.Description IS NULL THEN s.PlanDescription ELSE so.Description END AS [SubscriptionDescription]  
		, s.Reference AS [SubscriptionReference]
		, st.[Name] as [SubscriptionStatus]
		, pp.Code AS [ProductCode]  
		, sp.Id AS [SubscriptionProductId]  
		, CASE WHEN spo.Id IS NULL AND spo.Name IS NULL THEN sp.PlanProductName ELSE spo.Name END AS SubscriptionProductName  
		, CASE WHEN spo.Id IS NULL AND spo.Description IS NULL THEN sp.PlanProductDescription ELSE spo.Description END AS SubscriptionProductDescription
		, sp.Quantity as SubscriptionProductQuantity
		, CASE WHEN sp.Included = 1 THEN 'Yes' ELSE 'No' END AS CurrentSubscriptionProductInclusion
		, NULL AS TargetSubscriptionProductInclusion
	FROM Customer c
		INNER JOIN Subscription s ON c.Id = s.CustomerId
		INNER JOIN SubscriptionProduct sp ON s.Id = sp.SubscriptionId
		INNER JOIN PlanProduct pp ON pp.Id = sp.PlanProductId
		INNER JOIN [Plan] p ON p.Id = s.PlanId
		LEFT JOIN @planProductIds planprod ON pp.Id = planprod.Id
		LEFT JOIN @productIds prod on prod.Id = pp.ProductId
		LEFT JOIN SubscriptionOverride so ON s.Id = so.Id
		LEFT JOIN SubscriptionProductOverride spo ON sp.Id = spo.Id
		INNER JOIN Lookup.SubscriptionStatus st ON st.Id = s.StatusId
	WHERE c.AccountId = @accountId 
	    AND (s.[PlanFrequencyId] = @planFrequencyId OR @planFrequencyId = 0) --planFrequencyId 0 means "All Plans"
		AND s.IsDeleted = 0
		AND s.StatusId NOT IN (3, 6, 7) -- not in cancelled, suspended nor migrated
		AND (@customerId IS NULL OR s.CustomerId = @customerId)
		and (@allPlanProducts = 1 OR planprod.Id IS NOT NULL OR prod.Id IS NOT NULL)
	ORDER BY c.Id, s.Id
END

GO

