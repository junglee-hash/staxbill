
CREATE PROCEDURE [Reporting].[FuneralDirectors_SubscriptionProductTrackedItems]
	@AccountId BIGINT 
AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL SNAPSHOT

BEGIN

	--CTE created as workaround to open Billing Period bug - remove duplicated Billing periods by BillingPeriodDefinitionId, PeriodStatusId
	;WITH [BillingPeriod_Cleaned] AS (
		SELECT BillingPeriodDefinitionId,PeriodStatusId,CustomerId,CreatedTimestamp,ModifiedTimestamp,StartDate,EndDate
		FROM (
			SELECT *
			,ROW_NUMBER() OVER (PARTITION BY BillingPeriodDefinitionId,PeriodStatusId ORDER BY [ModifiedTimestamp] DESC) AS [RowNumber]
			FROM BillingPeriod
			WHERE PeriodStatusId = 1
			) bp
		WHERE [RowNumber] = 1
		)

	SELECT 
	c.Id AS [Fusebill Id]
	,ISNULL(c.Reference,'') AS [Customer Id]
	,ISNULL(c.FirstName,'') AS [Customer First Name]
	,ISNULL(c.LastName,'') AS [Customer Last Name]
	,ISNULL(c.CompanyName,'') AS [Customer Company Name]
	,ISNULL(glc.Code,'') AS [Product GL Code]
	,ISNULL([pi].[Name],'') AS [Tracked Item Name]
	,ISNULL([pi].[Description],'') AS [Tracked Item Description]
	,[pi].[Reference] AS [Tracked Item Reference]
	,lspis.[Name] AS [Tracked Item Status]
	,COALESCE(spo.[Name],sp.PlanProductName) AS [Subscription Product Name]
	,lsps.[Name] AS [Subscription Product Status]
	,sp.PlanProductCode AS [Subscription Product Code]
	,CASE WHEN afc.MrrDisplayTypeId = 1 THEN sp.MonthlyRecurringRevenue ELSE sp.CurrentMrr END AS [Subscription Product MRR]
	,CASE WHEN afc.MrrDisplayTypeId = 1 THEN sp.NetMrr ELSE sp.CurrentNetMrr END AS [Subscription Product Net MRR]
	,sp.Quantity AS [Subscription Product Quantity]
	,sp.IsTrackingItems AS [Subscription Product Is Tracking Items]
	,lett.[Name] AS [Subscription Product Earning Timing Type]
	,COALESCE(CONVERT(VARCHAR(20),CONVERT(DATETIME,dbo.fn_ConvertDateTimeToSmallDateTimeWithTimezone(sp.StartDate,TimezoneId )), 120), '') AS [Subscription Product Start Timestamp]
	,CASE WHEN (sp.StatusId = 1 AND bp.EndDate IS NOT NULL AND bp.EndDate < '9999-01-01' AND s.RemainingInterval IS NOT NULL) 
			THEN COALESCE(CONVERT(VARCHAR(20),CONVERT(DATETIME,dbo.fn_ConvertDateTimeToSmallDateTimeWithTimezone(dbo.fn_CalculateExpiringDate(bp.EndDate,s.NumberOfIntervals,s.IntervalId,sp.RemainingInterval),TimezoneId )), 120), '')
			ELSE '' 
			END AS [Subscription Product Expiring Timestamp]
	,lss.[Name] as [Subscription Status]
	FROM Account a
	INNER JOIN AccountPreference ap ON a.Id = ap.Id
	INNER JOIN AccountFeatureConfiguration afc ON a.Id = afc.Id
	INNER JOIN Customer c ON c.AccountId = a.Id
	INNER JOIN Subscription s ON s.CustomerId = c.Id
	INNER JOIN SubscriptionProduct sp ON sp.SubscriptionId = s.Id
	INNER JOIN SubscriptionProductItem spi ON spi.SubscriptionProductId = sp.Id
	INNER JOIN ProductItem [pi] ON [pi].Id = spi.Id
	INNER JOIN Product p ON [pi].ProductId = p.Id
	INNER JOIN BillingPeriodDefinition bpd ON s.BillingPeriodDefinitionId = bpd.Id
	LEFT OUTER JOIN BillingPeriod_Cleaned bp ON bpd.Id = bp.BillingPeriodDefinitionId
	LEFT OUTER JOIN SubscriptionProductOverride spo ON spo.Id = sp.Id
	LEFT OUTER JOIN GLCode glc ON p.GlCodeId = glc.Id
	LEFT OUTER JOIN Lookup.SubscriptionProductStatus lsps ON sp.StatusId = lsps.Id
	LEFT OUTER JOIN Lookup.SubscriptionStatus lss ON s.StatusId = lss.Id
	LEFT OUTER JOIN Lookup.SubscriptionProductItemStatus lspis ON sp.StatusId = lspis.Id
	LEFT OUTER JOIN Lookup.EarningTimingType lett ON sp.EarningTimingTypeId = lett.Id 
	WHERE a.Id = @AccountId
	--OPTION (RECOMPILE)

END	

SET NOCOUNT OFF

GO

