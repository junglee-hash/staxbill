
CREATE PROCEDURE [Reporting].[usp_GetSubscriptionsForBulkEditCsv]

@AccountId bigint,
@Plans IDList readonly,
@Statuses IDList readonly,
@Frequencies PlanFrequencySplitTableType readonly
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @HierarchyRollupEnabled BIT

	SELECT @HierarchyRollupEnabled = CustomerHierarchyRollup FROM AccountFeatureConfiguration WHERE Id = @AccountId

	DECLARE @SQL NVARCHAR(MAX)

	SET @SQL = 
		'
	SELECT 
		s.Id as SubscriptionId
		, c.Id as CustomerStaxBillId
		, c.Reference as CustomerId
		, c.FirstName as CustomerFirstName
		, c.LastName as CustomerLastName
		, c.CompanyName as CustomerCompanyName
		, s.PlanCode as PlanCode
		, CASE WHEN so.Id IS NOT NULL AND so.Name IS NOT NULL AND LEN(so.Name) > 0 
			THEN so.Name ELSE s.PlanName END as SubscriptionName
		, CASE WHEN so.Id IS NOT NULL AND so.Description IS NOT NULL AND LEN(so.Description) > 0 
			THEN so.Description ELSE s.PlanDescription END as SubscriptionDescription
		, s.Reference as SubscriptionReference
		, s.ContractStartTimestamp as ContractStartDate
		, s.ContractEndTimestamp as ContractEndDate
		, s.[ScheduledActivationTimestamp]
		, s.[RemainingInterval] as ExpiryPeriods
		, s.[BillingPeriodDefinitionId]
		'

	IF @HierarchyRollupEnabled = 1
	BEGIN
		SET @SQL = @SQL  +  '
		, CASE WHEN bpd.CustomerId = s.CustomerId 
			THEN ''InvoiceThisCustomer'' ELSE ''InvoiceParent'' END as InvoiceOwner
		'
	END

	SET @SQL = @SQL  +  '
	FROM Subscription s
	INNER JOIN @Plans p ON p.Id = s.PlanId'

	IF ((SELECT COUNT(*) FROM @Statuses) > 0)
	BEGIN
		SET @SQL = @SQL  +  '
		INNER JOIN @Statuses st ON st.Id = s.StatusId'
	END

	IF ((SELECT COUNT(*) FROM @Frequencies) > 0)
	BEGIN
		SET @SQL = @SQL  +  '
		INNER JOIN @Frequencies f ON f.Interval = s.IntervalId
		AND f.NumberOfIntervals = s.NumberOfIntervals'
	END

	SET @SQL = @SQL  +  '
	INNER JOIN Customer c ON c.Id = s.CustomerId
		AND c.AccountId = @AccountId
		AND c.IsDeleted = 0
	LEFT JOIN SubscriptionOverride so ON so.Id = s.Id
	LEFT JOIN BillingPeriodDefinition bpd ON bpd.Id = s.[BillingPeriodDefinitionId]
	WHERE s.IsDeleted = 0'
	 
	--PRINT(@SQL)
		
	EXEC sp_executesql @SQL ,N'@AccountId BIGINT,@Plans IDList readonly,@Statuses IDList readonly,@Frequencies PlanFrequencySplitTableType readonly'
	,@AccountId,@Plans,@Statuses,@Frequencies
END

GO

