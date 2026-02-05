CREATE PROCEDURE [dbo].[usp_GetSubscriptionProductLabelsExport]  
 @accountId BIGINT,  
 @planProductIds AS dbo.IDList READONLY,
 @planFrequencyId BIGINT, 
 @allPlanProducts bit,
 @returnExcluded BIT  
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
		, pp.Code AS [ProductCode]  
		, sp.Id AS [SubscriptionProductId]  
		, CASE WHEN spo.Id IS NULL AND spo.Name IS NULL THEN sp.PlanProductName ELSE spo.Name END AS SubscriptionProductName  
		, CASE WHEN spo.Id IS NULL AND spo.Description IS NULL THEN sp.PlanProductDescription ELSE spo.Description END AS SubscriptionProductDescription  
		, NULL AS TargetSubscriptionProductName
		, NULL AS TargetSubscriptionProductDescription
	FROM Customer c  
		INNER JOIN Subscription s ON c.Id = s.CustomerId  
		INNER JOIN SubscriptionProduct sp ON s.Id = sp.SubscriptionId   
		INNER JOIN PlanProduct pp ON pp.Id = sp.PlanProductId  
		INNER JOIN [Plan] p ON p.Id = s.PlanId  
		left JOIN @planProductIds prod ON pp.Id = prod.Id
		LEFT JOIN SubscriptionOverride so ON s.Id = so.Id  
		LEFT JOIN SubscriptionProductOverride spo ON sp.Id = spo.Id  
	WHERE c.AccountId = @accountId and s.[PlanFrequencyId] = @planFrequencyId and (@returnExcluded = 1 or sp.Included = 1)  
		AND s.IsDeleted = 0
		AND s.StatusId NOT IN (3, 7) -- not in cancelled nor migrated
		and (@allPlanProducts = 1 or prod.Id is not null)
	ORDER BY c.Id, s.Id  
END

GO

