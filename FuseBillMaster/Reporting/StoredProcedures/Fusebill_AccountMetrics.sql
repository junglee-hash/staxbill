CREATE PROCEDURE [Reporting].[Fusebill_AccountMetrics]
AS
BEGIN

set nocount on



-- Summary Results
SELECT 
	COUNT([Account Id]) as [Live Accounts]
	, ISNULL(SUM([Active Customers]), 0) as [Current Customers]
	, ISNULL(SUM([Active Subscriptions]), 0) as [Current Subscriptions]
FROM Reporting.AccountProfile
WHERE Live = 'Yes'

-- Results for Graph
SELECT 
	ISNULL(SUM(CASE WHEN [Tax Option] = 'Basic Taxation' THEN 1 ELSE 0 END),0) as [Basic Taxation]
	, ISNULL(SUM(CASE WHEN [Tax Option] = 'Advanced Taxation' THEN 1 ELSE 0 END), 0) as [Advanced Taxation]
	, ISNULL(SUM(CASE WHEN [Tax Option] = 'Avalara Direct Taxation' THEN 1 ELSE 0 END), 0) as [Avalara Direct]
	, ISNULL(SUM(CASE WHEN [Currencies] > 1 THEN 1 ELSE 0 END), 0) as [Multiple Currencies]
	, ISNULL(SUM(CASE WHEN [Api Key] = 'None' THEN 0 ELSE 1 END), 0) as [Api Integration]
	, ISNULL(SUM(CASE WHEN [Salesforce Enabled] = 'Yes' THEN 1 ELSE 0 END), 0) as [Salesforce]
	, ISNULL(SUM(CASE WHEN [Hubspot Configured] = 'Yes' THEN 1 ELSE 0 END), 0) as [Hubspot]
	, ISNULL(SUM(CASE WHEN [Netsuite Enabled] = 'Yes'  THEN 1 ELSE 0 END), 0) as [NetSuite]
	, ISNULL(SUM(CASE WHEN [QuickBooks Enabled] = 'Yes'  THEN 1 ELSE 0 END), 0) as [QuickBooks]
	, ISNULL(SUM(CASE WHEN [Paypal Enabled] = 'Yes'  THEN 1 ELSE 0 END), 0) as [Paypal]
	, ISNULL(SUM(CASE WHEN [Geotab Configured] = 'Yes'  THEN 1 ELSE 0 END), 0) as [Geotab Configured]
	, ISNULL(SUM(CASE WHEN [Webhooks Enabled] = 'Yes'  THEN 1 ELSE 0 END), 0) as [Webhooks]
	, ISNULL(SUM(CASE WHEN [Coupons (Number of)] > 1 THEN 1 ELSE 0 END), 0) as [Coupons]
	, ISNULL(SUM(CASE WHEN [Discounts] = 'Yes' THEN 1 ELSE 0 END), 0) as [Discounts]
	, ISNULL(SUM(CASE WHEN [Custom Fields (Number of)] > 1 THEN 1 ELSE 0 END), 0) as [Custom Fields]
	, ISNULL(SUM(CASE WHEN [Sales Tracking Codes (Number of)] > 1 THEN 1 ELSE 0 END), 0) as [Sales Tracking Codes]
	, ISNULL(SUM(CASE WHEN [Account Service Provider] = 'StaxBill' THEN 1 ELSE 0 END), 0) as [Stax Bill]
	, ISNULL(SUM(CASE WHEN [Account Service Provider] = 'Stax Bill Flex' THEN 1 ELSE 0 END), 0) as [Stax Bill Flex]
FROM Reporting.AccountProfile
WHERE Live = 'Yes'


END

GO

