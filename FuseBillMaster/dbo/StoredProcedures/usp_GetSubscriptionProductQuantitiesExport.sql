CREATE PROCEDURE [dbo].[usp_GetSubscriptionProductQuantitiesExport]
    @AccountId bigint,
    @PlanProductIds varchar(max),
	@ProductIds varchar(max),
    @PlanFrequencyId bigint,
	@AllPlanProducts bit,
    @ReturnExcluded bit
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

declare @planProducts table
(
PlanProductId bigint
)

declare @products table
(
ProductId bigint
)


if @PlanFrequencyId = 0 
	begin
		INSERT INTO @products (ProductId)
		select Data from dbo.Split (@ProductIds,'|')

		SELECT 
			c.Id as [FusebillId]
			, c.Reference as [CustomerId]
			, c.FirstName as [CustomerFirstName]
			, c.LastName as [CustomerLastName]
			, c.CompanyName as [CustomerCompanyName]
			, p.Code as [PlanCode]
			, s.Id as [SubscriptionId]
			, CASE WHEN so.Id IS NULL AND so.Name IS NULL
				THEN s.PlanName
				ELSE so.Name
				END as [SubscriptionName]
			, CASE WHEN so.Id IS NULL AND so.Description IS NULL
				THEN s.PlanDescription
				ELSE so.Description
				END as [SubscriptionDescription]
			, s.Reference as [SubscriptionReference]
			, pp.Code as [ProductCode]
			, sp.Id as [SubscriptionProductId]
			, CASE WHEN spo.Id IS NULL AND spo.Name IS NULL
				THEN sp.PlanProductName
				ELSE spo.Name
				END as [SubscriptionProductName]
			, CASE WHEN spo.Id IS NULL AND spo.Description IS NULL
				THEN sp.PlanProductDescription
				ELSE spo.Description
				END as [SubscriptionProductDescription]
			, sp.Quantity as [CurrentQuantity]
			, NULL as [TargetQuantity]
		FROM Customer c
			inner JOIN Subscription s ON c.Id = s.CustomerId
			inner JOIN SubscriptionProduct sp ON s.Id = sp.SubscriptionId 
			inner JOIN PlanProduct pp ON pp.Id = sp.PlanProductId
			inner JOIN [Plan] p ON p.Id = s.PlanId
			inner JOIN @products prod ON pp.ProductId = prod.ProductId
			LEFT JOIN SubscriptionOverride so ON s.Id = so.Id
			LEFT JOIN SubscriptionProductOverride spo ON sp.Id = spo.Id
		WHERE 
			c.AccountId = @AccountId
			AND s.IsDeleted = 0
			AND s.StatusId NOT IN (3, 7) -- not in cancelled nor migrated
			AND (@ReturnExcluded = 1 OR sp.Included = 1)
		ORDER BY c.Id, s.Id
	end 
else 
	begin
		INSERT INTO @planProducts (PlanProductId)
		select Data from dbo.Split (@PlanProductIds,'|')

		SELECT 
			c.Id as [FusebillId]
			, c.Reference as [CustomerId]
			, c.FirstName as [CustomerFirstName]
			, c.LastName as [CustomerLastName]
			, c.CompanyName as [CustomerCompanyName]
			, p.Code as [PlanCode]
			, s.Id as [SubscriptionId]
			, CASE WHEN so.Id IS NULL AND so.Name IS NULL
				THEN s.PlanName
				ELSE so.Name
				END as [SubscriptionName]
			, CASE WHEN so.Id IS NULL AND so.Description IS NULL
				THEN s.PlanDescription
				ELSE so.Description
				END as [SubscriptionDescription]
			, s.Reference as [SubscriptionReference]
			, pp.Code as [ProductCode]
			, sp.Id as [SubscriptionProductId]
			, CASE WHEN spo.Id IS NULL AND spo.Name IS NULL
				THEN sp.PlanProductName
				ELSE spo.Name
				END as [SubscriptionProductName]
			, CASE WHEN spo.Id IS NULL AND spo.Description IS NULL
				THEN sp.PlanProductDescription
				ELSE spo.Description
				END as [SubscriptionProductDescription]
			, sp.Quantity as [CurrentQuantity]
			, NULL as [TargetQuantity]
		FROM Customer c
			INNER JOIN Subscription s ON c.Id = s.CustomerId
			INNER JOIN SubscriptionProduct sp ON s.Id = sp.SubscriptionId 
			INNER JOIN PlanProduct pp ON pp.Id = sp.PlanProductId
			INNER JOIN [Plan] p ON p.Id = s.PlanId
			left JOIN @planProducts prod ON pp.Id = prod.PlanProductId
			LEFT JOIN SubscriptionOverride so ON s.Id = so.Id
			LEFT JOIN SubscriptionProductOverride spo ON sp.Id = spo.Id
		WHERE 
			c.AccountId = @AccountId 
			AND s.[PlanFrequencyId] = @PlanFrequencyId 
			AND (@ReturnExcluded = 1 
			OR sp.Included = 1)
			AND s.IsDeleted = 0
			AND s.StatusId NOT IN (3, 7) -- not in cancelled nor migrated
			and (@AllPlanProducts = 1 or prod.PlanProductId is not null)
		ORDER BY c.Id, s.Id
	end

END

GO

