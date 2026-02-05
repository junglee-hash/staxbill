CREATE   PROCEDURE [Reporting].[Update_Fusebill_AccountMetrics]
@FusebillAccountID nvarchar(50) = null
AS
BEGIN

SET NOCOUNT ON

TRUNCATE TABLE Reporting.AccountProfile

INSERT INTO Reporting.AccountProfile
SELECT
	a.Id as AccountId
	,a.CompanyName as CompanyName
	,tz.DisplayName as Timezone
	,at.Name as Type
	,CASE WHEN a.Live = 1 THEN 'Yes' ELSE 'No' END as Live
	,a.LiveTimestamp as LiveTimestamp
	,null as FirstPostedInvoice
	,lto.Name as TaxOption
	,0 as Currencies
	,'' as DunningDays
	,'None' as ApiKey
	,CASE WHEN afc.SalesforceEnabled = 1 THEN 'Yes' ELSE 'No' END as SalesforceEnabled
	,CASE WHEN afc.NetsuiteEnabled = 1 THEN 'Yes' ELSE 'No' END as NetsuiteEnabled
	,CASE WHEN afc.PaypalEnabled = 1 THEN 'Yes' ELSE 'No' END as PaypalEnabled
	,CASE WHEN afc.WebhooksEnabled = 1 THEN 'Yes' ELSE 'No' END as WebhooksEnabled
	,CASE WHEN afc.QuickBooksEnabled = 1 THEN 'Yes' ELSE 'No' END as QuickBooksEnabled
	,0 as Coupons
	,'No' as Discounts
	,0 as EnabledEmails
	,'No' as ProductItems
	,0 as CustomFields
	,0 as SalesTrackingCodes
	,'No' as SelfServicePortal
	,0 as RegistrationPages
	,0 as CustomReports
	,0 as ActiveCustomers
	,0 as ActiveSubscriptions
	,0 as ProductsPerSubscription
	,0 as IncludedProductsPerSubscription
	,0 as AvgTrackedItemsPerProduct
	,0 as MaxTrackedItemsPerProduct
	,0 as NumberOfPlans
	,0 as NumberOfProducts
	,0 as DataWeight
	,0 as UserCount
	,0 as EnabledUserCount
	,CASE WHEN afc.HubSpotConfigured = 1 THEN 'Yes' ELSE 'No' END as HubspotConfigured
	,0 as GeotabConfigured
	,CASE WHEN a.OriginUrlForPublicApiKey IS NOT Null OR a.OriginUrlForPublicApiKey = '' THEN 'Yes' ELSE 'No' END as TransparentRedirectEnabled
	,asp.ServiceProvider as AccountServiceProvider
	,a.CreatedTimestamp as CreatedTimestamp
	,a.FusebillIncId
	,'' as NetMRR
	,'' as LifetimeValue
	,CASE WHEN afc.MilestoneEarningEnabled = 1 THEN 'Yes' ELSE 'No' END as MilestoneEarningEnabled
	,'No' as IsSalesforceActive
	,abp.BillingEmail as PrimaryEmail
	,'' as CustomerStatus
	,abp.WebsiteUrl as [Website URL]
	,a.ShutdownDate as [Closure Date]
	,a.ShutdownReason as [Closure Reason]
	,'' as [Owner Name] -- set below
	,'' as [Contact Name] -- set below
	,abp.Address1 as [Address line 1]
	,abp.Address2 as [Address line 2]
	,abp.City as [City]
	,abp.PostalZip as [Zip code]
	,s.[Name] as [State]
	,c.[Name] as Country
FROM Account (NOLOCK) a
INNER JOIN AccountFeatureConfiguration (NOLOCK) afc ON a.Id = afc.Id
INNER JOIN AccountPreference (NOLOCK) ap ON a.Id = ap.Id
INNER JOIN Lookup.Timezone tz (NOLOCK) ON tz.Id = ap.TimezoneId
INNER JOIN Lookup.TaxOption lto (NOLOCK) ON lto.Id = afc.TaxOptionId
INNER JOIN AccountSalesTrackingCodeConfiguration astcc (NOLOCK) ON a.Id = astcc.Id
INNER JOIN Lookup.AccountType at (NOLOCK) ON at.Id = a.TypeId
INNER JOIN AccountServiceProviderTemplate asp (NOLOCK) ON asp.Id = a.AccountServiceProviderId
INNER JOIN AccountBrandingPreference abp (NOLOCK) ON a.Id = abp.Id
LEFT JOIN Lookup.[State] s (NOLOCK) ON s.Id = abp.StateId
LEFT JOIN Lookup.Country c (NOLOCK) ON c.Id = abp.CountryId

;WITH FirstPostedInvoice AS(
SELECT
	MIN(i.PostedTimestamp) as PostedTimestamp,
	i.AccountId
FROM Reporting.AccountProfile ap
INNER JOIN Invoice i on i.AccountId = ap.[Account ID]
GROUP BY i.[AccountId])
UPDATE ap
SET 
	ap.[First Posted Invoice] = fpi.PostedTimestamp
FROM Reporting.AccountProfile ap
INNER JOIN FirstPostedInvoice fpi on fpi.AccountId = ap.[Account ID]

UPDATE ap
SET 
	ap.[Api Key] = aks.Name 
FROM Reporting.AccountProfile ap
INNER JOIN AccountApiKey aak (NOLOCK) ON aak.AccountId = ap.[Account ID]
INNER JOIN Lookup.ApiKeyStatus aks (NOLOCK) ON aks.Id = aak.ApiKeyStatusId
WHERE aak.ApiKeyTypeId = 2

UPDATE ap
SET
ap.[NetMRR] = co.NetMRR,
ap.[LifeTimeValue] = co.LifeTimeValue,
ap.[PrimaryEmail] = co.PrimaryEmail,
ap.[CustomerStatus] = cs.Name
FROM Reporting.AccountProfile ap
INNER JOIN vw_CustomerOverview co ON co.Id = ap.FusebillIncId
INNER JOIN Lookup.CustomerStatus cs ON cs.Id = co.CustomerStatusId
WHERE @FusebillAccountID = co.AccountId

UPDATE ap
SET 
	ap.[IsSalesforceActive] = CASE WHEN asfc.IsActive = 1 THEN 'Yes' ELSE 'No' END 
FROM Reporting.AccountProfile ap
INNER JOIN AccountSalesforceConfiguration asfc (NOLOCK) ON asfc.Id = ap.[Account ID]

;WITH ActiveCustomers AS (
	SELECT
		AccountId
		,COUNT(*) as ActiveCustomers
	FROM Customer (NOLOCK) 
	WHERE StatusId IN (2,4,5)
	GROUP BY AccountId
)
UPDATE ap
SET ap.[Active Customers] = c.ActiveCustomers
FROM Reporting.AccountProfile ap
INNER JOIN ActiveCustomers c (NOLOCK) ON c.AccountId = ap.[Account ID]

;WITH ActiveSubscriptions AS (
	SELECT
		AccountId
		,COUNT(*) as ActiveSubscriptions
	FROM Subscription s (NOLOCK) 
	WHERE s.StatusId IN (2,4,6)
	GROUP BY AccountId
)
UPDATE ap
SET ap.[Active Subscriptions] = s.ActiveSubscriptions
FROM Reporting.AccountProfile ap
INNER JOIN ActiveSubscriptions s (NOLOCK) ON s.AccountId = ap.[Account ID]

;WITH SalesTrackingCodes AS (
	SELECT
		AccountId
		,COUNT(*) as Codes
	FROM SalesTrackingCode s (NOLOCK) 
	GROUP BY AccountId
)
UPDATE ap
SET ap.[Sales Tracking Codes (Number of)] = s.Codes
FROM Reporting.AccountProfile ap
INNER JOIN SalesTrackingCodes s (NOLOCK) ON s.AccountId = ap.[Account ID]

;WITH CustomReports AS (
	SELECT
		AccountId
		,COUNT(*) as CustomReports
	FROM Report (NOLOCK) 
	GROUP BY AccountId
)
UPDATE ap
SET ap.[Custom Reports] = c.CustomReports
FROM Reporting.AccountProfile ap
INNER JOIN CustomReports c (NOLOCK)  ON c.AccountId = ap.[Account ID]

;WITH RegistrationPages AS (
	SELECT
		AccountId
		,COUNT(*) as ActivePages
	FROM HostedPage h (NOLOCK) 
	WHERE h.HostedPageStatusId = 2
		AND h.HostedPageTypeId = 1
	GROUP BY AccountId
)
UPDATE ap
SET ap.[Registration Pages] = c.ActivePages
FROM Reporting.AccountProfile ap
INNER JOIN RegistrationPages c  (NOLOCK) ON c.AccountId = ap.[Account ID]

UPDATE ap
SET ap.[Self Service Portal] = 'Yes'
FROM Reporting.AccountProfile ap
INNER JOIN HostedPage c  (NOLOCK) ON c.AccountId = ap.[Account ID]
WHERE c.HostedPageTypeId = 2
	AND c.HostedPageStatusId = 2

;WITH Currencies AS (
	SELECT
		AccountId
		,COUNT(*) as Currencies
	FROM AccountCurrency (NOLOCK) 
	WHERE CurrencyStatusId = 2
	GROUP BY AccountId
)
UPDATE ap
SET ap.Currencies = c.Currencies
FROM Reporting.AccountProfile ap
INNER JOIN Currencies c  (NOLOCK) ON c.AccountId = ap.[Account ID]

;WITH Dunning AS (
SELECT
	AccountId
	,STUFF((SELECT ',' + CONVERT(varchar,Day)
            FROM AccountCollectionSchedule iacs (NOLOCK) 
			WHERE iacs.AccountId = acs.AccountId
			ORDER BY iacs.Day
            FOR XML PATH('')) ,1,1,'') as DunningDays
FROM AccountCollectionSchedule acs (NOLOCK) 
)
UPDATE ap
SET ap.[Dunning Days] = d.DunningDays
FROM Reporting.AccountProfile ap
INNER JOIN Dunning d ON d.AccountId = ap.[Account ID]

;WITH AccountEmails AS (
	SELECT
		AccountId
		,COUNT(*) as EnabledEmails
	FROM AccountEmailTemplate (NOLOCK) 
	WHERE Enabled = 1
	GROUP BY AccountId
)
UPDATE ap
SET ap.[Enabled Emails] = ae.EnabledEmails
FROM Reporting.AccountProfile ap
INNER JOIN AccountEmails ae  (NOLOCK) ON ae.AccountId = ap.[Account ID]

;WITH Coupons AS (
SELECT
	AccountId
	,COUNT(*) as Coupons
FROM Coupon (NOLOCK) 
WHERE StatusId >= 2
GROUP BY AccountId
)
UPDATE ap
SET ap.[Coupons (Number of)] = c.Coupons
FROM Reporting.AccountProfile ap
INNER JOIN Coupons c  (NOLOCK) ON ap.[Account ID] = c.AccountId

;WITH Discounts AS (
SELECT
	AccountId
FROM Discount d (NOLOCK) 
INNER JOIN [Transaction] t ON d.Id = t.Id
GROUP BY t.AccountId
)
UPDATE ap
SET ap.Discounts = 'Yes'
FROM Reporting.AccountProfile ap
INNER JOIN Discounts c  (NOLOCK) ON ap.[Account ID] = c.AccountId

;WITH ProductItems AS (
SELECT
	AccountId
FROM ProductItem pi (NOLOCK) 
INNER JOIN Product p  (NOLOCK) ON p.Id = pi.Productid
GROUP BY AccountId
)
UPDATE ap
SET ap.[Tracked Items] = 'Yes'
FROM Reporting.AccountProfile ap
INNER JOIN ProductItems c  (NOLOCK) ON ap.[Account ID] = c.AccountId

;WITH CustomFields AS (
SELECT
	AccountId
	,COUNT(*) as CustomFields
FROM CustomField (NOLOCK) 
GROUP BY AccountId
)
UPDATE ap
SET ap.[Custom Fields (Number of)] = c.CustomFields
FROM Reporting.AccountProfile ap
INNER JOIN CustomFields c  (NOLOCK) ON ap.[Account ID] = c.AccountId

;WITH SubscriptionStats AS 
(
SELECT
	ss.AccountId
	,SUM(ss.NumberOfSubscriptionProducts) / COUNT(*) as ProductsPerSubscription
	,SUM(ss.IncludedSubscriptionProducts) / COUNT(*) as IncludedProductsPerSubscription
FROM (
	SELECT
		c.AccountId
		,s.Id as SubscriptionId
		,COUNT(*) as NumberOfSubscriptionProducts
		,SUM(CONVERT(int,Included)) as IncludedSubscriptionProducts
	FROM SubscriptionProduct sp (NOLOCK) 
	INNER JOIN Subscription s (NOLOCK)  ON s.Id = sp.SubscriptionId
	INNER JOIN Customer c (NOLOCK)  ON c.Id = s.CustomerId
	WHERE s.StatusId = 2
	GROUP BY s.Id, c.AccountId) as ss
	GROUP BY 
	ss.AccountId
)
UPDATE ap
SET ap.[Products Per Subscription] = ss.ProductsPerSubscription
	,ap.[Included Products Per Subscription] = ss.IncludedProductsPerSubscription
FROM Reporting.AccountProfile ap
INNER JOIN SubscriptionStats ss  (NOLOCK) ON ap.[Account ID] = ss.AccountId

;WITH Plans AS (
SELECT
	AccountId
	,COUNT(*) as NumberOfPlans
FROM [Plan] (NOLOCK) 
GROUP BY AccountId
)
UPDATE ap
SET ap.[Number Of Plans] = p.NumberOfPlans
FROM Reporting.AccountProfile ap
INNER JOIN Plans p  (NOLOCK) ON p.AccountId = ap.[Account ID]

;WITH Products AS (
SELECT
	AccountId
	,COUNT(*) as NumberOfProducts
FROM Product (NOLOCK) 
GROUP BY AccountId
)
UPDATE ap
SET ap.[Number Of Products] = p.NumberOfProducts
FROM Reporting.AccountProfile ap
INNER JOIN Products p  (NOLOCK) ON p.AccountId = ap.[Account ID]

;WITH TrackedItemsPerProduct AS (
	SELECT
		AccountId
		,SUM(TrackedItemsPerProduct) / COUNT (TrackedItemsPerProduct) as AvgTrackedItemsPerProduct
		,MAX(TrackedItemsPerProduct) as MaxTrackedItemsPerProduct
	FROM (
		SELECT
			c.AccountId
			,sp.Id as SubscriptionProductId
			,COUNT(*) as TrackedItemsPerProduct
		FROM SubscriptionProductItem spi (NOLOCK) 
		INNER JOIN SubscriptionProduct sp  (NOLOCK) ON sp.Id = spi.SubscriptionProductId
		INNER JOIN Subscription s  (NOLOCK) ON s.Id = sp.SubscriptionId
		INNER JOIN Customer c  (NOLOCK) ON c.Id = s.CustomerId
		WHERE s.StatusId IN (2,4) --Active, provisioning
		GROUP BY c.AccountId,sp.Id
	) d
	GROUP BY AccountId
)
UPDATE ap
SET ap.[Avg Tracked Items Per Product] = dg.AvgTrackedItemsPerProduct
	,ap.[Max Tracked Items Per Product] = dg.MaxTrackedItemsPerProduct
FROM Reporting.AccountProfile ap
INNER JOIN TrackedItemsPerProduct dg ON dg.AccountId = ap.[Account ID]


;WITH Customers AS (
SELECT
	AccountId
	,COUNT(*) as NumberOfCustomers
FROM Customer (NOLOCK) 
GROUP BY AccountId
),

SubscriptionsAndProducts AS (
SELECT 
	subs.AccountId AS AccountId
	,COUNT(*) AS NumberOfSubscriptions
	,SUM(subs.SubscriptionProductCount) AS NumberOfSubscriptionProducts
FROM
(
	SELECT
		c.AccountId AccountId
		,sp.SubscriptionId
		,COUNT(*) AS SubscriptionProductCount
		FROM Subscription s (NOLOCK) 
		INNER JOIN Customer c (NOLOCK) ON c.Id = s.CustomerId 
		LEFT JOIN SubscriptionProduct sp (NOLOCK) ON s.Id = sp.SubscriptionId 
		GROUP BY c.AccountId,sp.SubscriptionId) AS subs 
	GROUP BY  subs.AccountId
)

UPDATE ap
SET ap.[Data Weight] = (NumberOfCustomers / 1000.0) * (NumberOfSubscriptions / 1000.0) * (NumberOfSubscriptionProducts / 1000.0) 
FROM Reporting.AccountProfile ap
INNER JOIN Customers c ON c.AccountId = ap.[Account ID]
INNER JOIN SubscriptionsAndProducts sap ON sap.AccountId = ap.[Account ID]


;WITH Users AS (
SELECT
	AccountId,
	UserCount,
	EnabledUserCount
FROM
	(
		SELECT
			au.AccountId,
			COUNT(UserId) AS UserCount,
			SUM(CASE WHEN IsEnabled = 1 THEN 1 ELSE 0 END) as EnabledUserCount
		FROM AccountUser au
		GROUP BY au.AccountId
	) AS Counts
)

UPDATE ap
SET ap.[User Count] = UserCount, ap.[Enabled User Count] = EnabledUserCount
FROM Reporting.AccountProfile ap
INNER JOIN Users u ON u.AccountId = ap.[Account ID]

UPDATE ap
SET ap.[Geotab Configured] = 
	CASE WHEN agc.GeotabAccountId IS NOT Null THEN 'Yes' ELSE 'No' END
FROM Reporting.AccountProfile ap
LEFT JOIN AccountGeotabConfiguration agc ON ap.[Account ID] = agc.Id

UPDATE ap
	SET ap.[Owner Name] = TRIM(u.FirstName + ' ' + u.LastName)
	, ap.[Contact Name] = TRIM(u.FirstName + ' ' + u.LastName)
FROM Reporting.AccountProfile ap
INNER JOIN AccountUser au (NOLOCK) ON ap.[Account ID] = au.AccountId
INNER JOIN AccountUserRole aur (NOLOCK) ON au.Id = aur.AccountUserId
	AND aur.RoleTypeId = 1
INNER JOIN [User] u ON u.Id = au.UserId

END

GO

