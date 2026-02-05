
CREATE PROCEDURE [dbo].[usp_GetActiveSubscriptionProductCountAndQuantity]

	@AccountId BIGINT
	, @StartDate DATETIME
	, @EndDate DATETIME
	, @PlanFrequencyUniqueId BIGINT = NULL
	, @PlanId BIGINT = NULL
	, @CurrencyId INT = NULL
	, @SalesTrackingCode1IdList NVARCHAR(2000) = NULL
	, @SalesTrackingCode2IdList NVARCHAR(2000) = NULL 
	, @SalesTrackingCode3IdList NVARCHAR(2000) = NULL
	, @SalesTrackingCode4IdList NVARCHAR(2000) = NULL 
	, @SalesTrackingCode5IdList NVARCHAR(2000) = NULL
AS

IF @StartDate IS NULL
	SET @StartDate = DATEADD(MONTH,-12,GETUTCDATE())
IF @EndDate IS NULL
	SET @EndDate = GETUTCDATE()

DECLARE @SQL NVARCHAR(MAX)
SET TRANSACTION ISOLATION LEVEL SNAPSHOT
	SET NOCOUNT ON

	CREATE TABLE #MostRecentJournals
	(
		SubscriptionStatusId INT
		,SubscriptionProductStatusId INT
		,SubscriptionProductIncludedStatus VARCHAR(50)
		,SubscriptionProductQuantity DECIMAL(18,6)
		,SalesTrackingCode1Id BIGINT NULL
		,SalesTrackingCode2Id BIGINT NULL
		,SalesTrackingCode3Id BIGINT NULL
		,SalesTrackingCode4Id BIGINT NULL
		,SalesTrackingCode5Id BIGINT NULL
		,CurrencyId BIGINT
		,ProductId BIGINT
		,PlanId BIGINT
		,PlanFrequencyUniqueId BIGINT
	)

	SELECT
		sp.Id as SubscriptionProductId
		,sp.ProductId
		,sp.SubscriptionId
		,s.PlanId
		,s.PlanFrequencyUniqueId
		,c.CurrencyId
	INTO #SubscriptionProducts
	FROM Product p
	INNER JOIN SubscriptionProduct sp ON p.Id = sp.ProductId
	INNER JOIN Subscription s ON s.Id = sp.SubscriptionId
	INNER JOIN Customer c ON c.Id = s.CustomerId
	WHERE p.AccountId = @AccountId
		AND c.AccountId = @AccountId
		AND c.CurrencyId = ISNULL(@CurrencyId,c.CurrencyId)
		AND s.PlanId = ISNULL(@PlanId,s.PlanId)
		AND s.PlanFrequencyUniqueId = ISNULL(@PlanFrequencyUniqueId, s.PlanFrequencyUniqueId)

	;WITH CTE_RankedJournals AS (
		SELECT 
		ROW_NUMBER() OVER (PARTITION BY spj.SubscriptionProductId ORDER BY spj.CreatedTimestamp DESC) AS [RowNumber]
		,spj.Id AS SubscriptionProductJournalId
		,spj.SubscriptionProductId
		,sp.ProductId
		,sp.PlanId
		,sp.PlanFrequencyUniqueId
		,sp.CurrencyId
		FROM SubscriptionProductJournal spj 
		INNER JOIN #SubscriptionProducts sp ON spj.SubscriptionProductId = sp.SubscriptionProductId
		WHERE spj.CreatedTimestamp <= @EndDate
		)
	
	--Second join to SubscriptionProductJournal to use existing indexes
	,CTE_SubscriptionProductJournals AS (
		SELECT 
		SubscriptionStatusId
		,SubscriptionProductStatusId
		,SubscriptionProductIncludedStatus
		,SubscriptionProductQuantity
		,SalesTrackingCode1Id
		,SalesTrackingCode2Id
		,SalesTrackingCode3Id
		,SalesTrackingCode4Id
		,SalesTrackingCode5Id
		,cte_rj.CurrencyId
		,cte_rj.ProductId
		,cte_rj.PlanId
		,cte_rj.PlanFrequencyUniqueId
		FROM SubscriptionProductJournal spj
		INNER JOIN CTE_RankedJournals cte_rj
		ON cte_rj.SubscriptionProductJournalId = spj.Id
		WHERE [RowNumber] = 1
		)

	INSERT INTO #MostRecentJournals
	SELECT * 
	FROM CTE_SubscriptionProductJournals

	DROP TABLE #SubscriptionProducts

	SELECT @SQL = N'
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT
	SET NOCOUNT ON	

	SELECT 
		mrj.ProductId AS Id
		,COUNT(mrj.SubscriptionProductQuantity) AS CountOfProducts
		,ISNULL(SUM(mrj.SubscriptionProductQuantity), 0) AS QuantityOfProducts
	INTO #Results
	FROM #MostRecentJournals mrj 
	WHERE mrj.SubscriptionProductStatusId = 1 
	AND mrj.SubscriptionProductIncludedStatus = ''Included'' 
	AND mrj.SubscriptionStatusId IN (2,4)
		' + CASE 
				WHEN @SalesTrackingCode1IdList IS NULL THEN 'AND mrj.SalesTrackingCode1Id IS NULL'
				WHEN @SalesTrackingCode1IdList = '' THEN ''
				else 'AND mrj.SalesTrackingCode1Id IN (' + @SalesTrackingCode1IdList +')' END + '
		' + CASE 
				WHEN @SalesTrackingCode2IdList IS NULL THEN 'AND mrj.SalesTrackingCode2Id IS NULL'
				WHEN @SalesTrackingCode2IdList = '' THEN ''
				else 'AND mrj.SalesTrackingCode2Id IN (' + @SalesTrackingCode2IdList +')' END + '
		' + CASE 
				WHEN @SalesTrackingCode3IdList IS NULL THEN 'AND mrj.SalesTrackingCode3Id IS NULL'
				WHEN @SalesTrackingCode3IdList = '' THEN ''
				else 'AND mrj.SalesTrackingCode3Id IN (' + @SalesTrackingCode3IdList +')' END + '
		' + CASE 
				WHEN @SalesTrackingCode4IdList IS NULL THEN 'AND mrj.SalesTrackingCode4Id IS NULL'
				WHEN @SalesTrackingCode4IdList = '' THEN ''
				else 'AND mrj.SalesTrackingCode4Id IN (' + @SalesTrackingCode4IdList +')' END + '
		' + CASE 
				WHEN @SalesTrackingCode5IdList IS NULL THEN 'AND mrj.SalesTrackingCode5Id IS NULL'
				WHEN @SalesTrackingCode5IdList = '' THEN ''
				else 'AND mrj.SalesTrackingCode5Id IN (' + @SalesTrackingCode5IdList +')' END + '
		' + CASE 
				WHEN @PlanId IS NOT NULL THEN 'AND mrj.PlanId = @PlanId' ELSE '' END + '
		' + CASE 
				WHEN @PlanFrequencyUniqueId IS NOT NULL THEN 'AND mrj.PlanFrequencyUniqueId = @PlanFrequencyUniqueId ' ELSE '' END + '
		' + CASE 
				WHEN @CurrencyId IS NOT NULL THEN 'AND mrj.CurrencyId = ' + CONVERT(VARCHAR(2),@CurrencyId) ELSE '' END + '
	GROUP BY mrj.ProductId
		
	SELECT
		p.Id
		,p.Name, p.Code
		,ISNULL(r.CountOfProducts,0) AS CountOfProducts
		,ISNULL(r.QuantityOfProducts,0) AS QuantityOfProducts
	FROM Product p
	LEFT OUTER JOIN #Results r ON p.Id = r.Id
	WHERE AccountId = @AccountId 
	ORDER BY CountOfProducts DESC
	OPTION (RECOMPILE)

	DROP TABLE #Results

	SET NOCOUNT OFF
	'
	

	--select @SQL
EXEC sp_executesql @SQL ,N'@StartDate DATETIME,@EndDate DATETIME,@AccountId BIGINT,@PlanId BIGINT,@PlanFrequencyUniqueId BIGINT,@CurrencyId INT'
	,@StartDate,@EndDate,@AccountId,@PlanId,@PlanFrequencyUniqueId,@CurrencyId --with recompile

	DROP TABLE #MostRecentJournals

GO

