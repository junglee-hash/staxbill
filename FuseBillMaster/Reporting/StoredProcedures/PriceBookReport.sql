


CREATE       PROCEDURE [Reporting].[PriceBookReport]
	@AccountId BIGINT
AS
BEGIN

	DECLARE @TimeZoneId INT
	SET @TimeZoneId = (SELECT TimezoneId FROM dbo.AccountPreference WHERE Id = @AccountId);


	WITH PricingData AS 
	(
		SELECT DISTINCT
			CASE WHEN otcc.PricingModelTypeId = 1 --standard
				THEN  CAST(p.Amount AS NVARCHAR)
				ELSE 'Varies' END
			AS [Amount]
			,otcc.Id AS OrderToCashCycleId
			,c.[IsoName]
		FROM dbo.Price p
		INNER JOIN dbo.QuantityRange qr ON qr.Id = p.QuantityRangeId
		INNER JOIN dbo.OrderToCashCycle otcc ON otcc.Id = qr.OrderToCashCycleId
		INNER JOIN Lookup.Currency c ON c.Id = p.CurrencyId
	), PriceBookPlanProducts AS
	(
		SELECT 
			pp.Id
			,potcc.PricebookId
			,i.[Name] AS [Interval]
			,pf.NumberOfIntervals
			,pp.[Code]
			,pp.[Name]
			,p.Id AS PlanId
			,p.[Code] AS PlanCode
			,p.[Name] AS PlanName
			,prd.Id AS ProductId
			,prd.[Code] AS ProductCode
			,prd.[Name] AS ProductName
		FROM dbo.PlanProduct pp
		INNER JOIN dbo.[product] prd ON prd.Id = pp.ProductId
		INNER JOIN dbo.PlanOrderToCashCycle potcc ON potcc.PlanProductId = pp.Id
		INNER JOIN dbo.PlanFrequency pf ON pf.Id = potcc.PlanFrequencyId
		INNER JOIN dbo.PlanRevision pr ON pr.Id = pf.PlanRevisionId
		INNER JOIN dbo.[Plan] p ON p.Id = pr.PlanId
		INNER JOIN Lookup.[Interval] i ON i.Id = pf.[Interval]
		WHERE p.IsDeleted = 0
	), SharedPriceBookColumns AS (
		SELECT
			pb.ID AS [Pricebook ID]
			,pb.Code AS [Pricebook Code]
			,pb.[Name] AS [Pricebook Name]
			,pb.[Description] AS [Pricebook Description]
			,CONVERT(SMALLDATETIME,dbo.fn_GetTimezoneTime(pb.CreatedTimestamp,@TimeZoneId)) AS [Created Date]
			,CONVERT(SMALLDATETIME,dbo.fn_GetTimezoneTime(pb.ModifiedTimestamp,@TimeZoneId)) AS [Modified Date]
			,pbe.Id AS [Pricebook Entry ID]
			,CASE 
				WHEN pbe.[Priority] > 0 
				THEN CAST(pbe.[Priority] AS NVARCHAR) 
				ELSE 'Default' END 
			AS [Pricebook Entry Priority]
			,CONVERT(SMALLDATETIME,dbo.fn_GetTimezoneTime(pbe.StartingDate,@TimeZoneId)) AS [Start Date]
			,CASE 
				WHEN otcc.PricingModelTypeId = 1 --Standard
				THEN COALESCE(pd.Amount, 'Varies')
				ELSE 'Varies' END
			AS [Price]
			,pd.IsoName AS [Currency]
		FROM dbo.PriceBook pb
		INNER JOIN dbo.PricebookEntry pbe ON pbe.PricebookId = pb.Id
		INNER JOIN OrderToCashCycle otcc ON otcc.Id = pbe.OrderToCashCycleId
		LEFT JOIN PricingData pd ON pd.OrderToCashCycleId = otcc.Id
		WHERE accountId = @AccountId
		AND pb.IsUsingDateBasedPricebook = 1
	)

	SELECT 
		u.[Type]
		,u.[Pricebook ID]
		,u.[Pricebook Code]
		,u.[Pricebook Name]
		,u.[Pricebook Description]
		,u.[Created Date]
		,u.[Modified Date]
		,u.[Pricebook Entry ID]
		,u.[Start Date]
		,u.[Price]
		,u.[Currency]
		,u.[Plan Product ID]
		,u.[Plan Product Code]
		,u.[Plan Product Name]
		,u.[Plan Frequency Interval]
		,u.[Plan Frequency Number Of Intervals]
		,u.[Plan ID]
		,u.[Plan Code]
		,u.[Plan Name]
		,u.[Product ID]
		,u.[Product Code]
		,u.[Product Name]
	FROM (
		--DEFAULT TYPES:
		SELECT 
			'Pricebook Default' AS [Type]
			,pb.*
			,NULL AS [Plan Product ID]
			,NULL AS [Plan Product Code]
			,NULL AS [Plan Product Name]
			,NULL AS [Plan Frequency Interval]
			,NULL AS [Plan Frequency Number Of Intervals]
			,NULL AS [Plan ID]
			,NULL AS [Plan Code]
			,NULL AS [Plan Name]
			,NULL AS [Product ID]
			,NULL AS [Product Code]
			,NULL AS [Product Name]
		FROM SharedPriceBookColumns pb
		WHERE pb.[Pricebook Entry Priority] = 'Default'

		UNION
		--Pricebook Entry TYPES:
		SELECT 
			'Pricebook Entry' AS [Type]
			,pb.*
			,NULL AS [Plan Product ID]
			,NULL AS [Plan Product Code]
			,NULL AS [Plan Product Name]
			,NULL AS [Plan Frequency Interval]
			,NULL AS [Plan Frequency Number Of Intervals]
			,NULL AS [Plan ID]
			,NULL AS [Plan Code]
			,NULL AS [Plan Name]
			,NULL AS [Product ID]
			,NULL AS [Product Code]
			,NULL AS [Product Name]
		FROM SharedPriceBookColumns pb
		WHERE pb.[Pricebook Entry Priority] <> 'Default'

		UNION
		-- Plan Product and Pricebook Default. --note that the plan product rows will essentially contain repeat data, which is as-designed
		SELECT 
			'Plan Product and Pricebook Default' AS [Type]
			,pb.*
			,pbpp.Id AS [Plan Product ID]
			,pbpp.[Code] AS [Plan Product Code]
			,pbpp.[Name] AS [Plan Product Name]
			,pbpp.[Interval] AS [Plan Frequency Interval]
			,pbpp.NumberOfIntervals AS [Plan Frequency Number Of Intervals]
			,pbpp.PlanId AS [Plan ID]
			,pbpp.PlanCode AS [Plan Code]
			,pbpp.PlanName AS [Plan Name]
			,pbpp.ProductId AS [Product ID]
			,pbpp.ProductCode AS [Product Code]
			,pbpp.ProductName AS [Product Name]
		FROM SharedPriceBookColumns pb
		INNER JOIN PriceBookPlanProducts pbpp ON pbpp.PriceBookId = pb.[Pricebook ID]
		WHERE pb.[Pricebook Entry Priority] = 'Default'

		UNION
		-- Plan Product and Pricebook Entry. --note that the plan product rows will essentially contain repeat data, which is as-designed
		SELECT 
			'Plan Product and Pricebook Entry' AS [Type]
			,pb.*
			,pbpp.Id AS [Plan Product ID]
			,pbpp.[Code] AS [Plan Product Code]
			,pbpp.[Name] AS [Plan Product Name]
			,pbpp.[Interval] AS [Plan Frequency Interval]
			,pbpp.NumberOfIntervals AS [Plan Frequency Number Of Intervals]
			,pbpp.PlanId AS [Plan ID]
			,pbpp.PlanCode AS [Plan Code]
			,pbpp.PlanName AS [Plan Name]
			,pbpp.ProductId AS [Product ID]
			,pbpp.ProductCode AS [Product Code]
			,pbpp.ProductName AS [Product Name]
		FROM SharedPriceBookColumns pb
		INNER JOIN PriceBookPlanProducts pbpp ON pbpp.PriceBookId = pb.[Pricebook ID]
		WHERE pb.[Pricebook Entry Priority] <> 'Default'

	) AS u
	ORDER BY [PriceBook ID] ASC, [Start Date] ASC, [Pricebook Entry Priority] ASC


END

GO

