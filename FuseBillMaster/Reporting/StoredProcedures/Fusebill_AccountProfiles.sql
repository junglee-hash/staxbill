CREATE PROCEDURE [Reporting].[Fusebill_AccountProfiles]
	@AccountId BIGINT = NULL
AS
BEGIN

--AccountId is not used, just there to be used in custom reports

set nocount on

SELECT [Account ID]
      ,[Company Name]
      ,[Timezone]
      ,[Type]
      ,[Live]
      ,[Live Timestamp]
      ,[First Posted Invoice]
      ,[Tax Option]
      ,[Currencies]
      ,[Dunning Days]
      ,[Api Key]
      ,[Salesforce Enabled]
      ,[IsSalesforceActive]
      ,[Netsuite Enabled]
      ,[Paypal Enabled]
      ,[Webhooks Enabled]
      ,[QuickBooks Enabled]
      ,[Coupons (Number of)]
      ,[Discounts]
      ,[Enabled Emails]
      ,[Tracked Items]
      ,[Custom Fields (Number of)]
      ,[Sales Tracking Codes (Number of)]
      ,[Self Service Portal]
      ,[Registration Pages]
      ,[Custom Reports]
      ,[Active Customers]
      ,[Active Subscriptions]
      ,[Products Per Subscription]
      ,[Included Products Per Subscription]
      ,[Avg Tracked Items Per Product]
      ,[Max Tracked Items Per Product]
      ,[Number Of Plans]
      ,[Number Of Products]
      ,[Data Weight]
      ,[User Count]
      ,[Enabled User Count]
      ,[Hubspot Configured]
      ,[Geotab Configured]
      ,[Transparent Redirect Enabled]
      ,[Account Service Provider]
      ,[Created Timestamp]
      ,[FusebillIncId]
      ,[NetMRR]
      ,[LifetimeValue]
      ,[MilestoneEarningEnabled]
	  ,[PrimaryEmail]
	  ,[CustomerStatus]
	  ,[Website URL]
	  ,[Closure Date]
	  ,[Closure Reason]
	  ,[Owner Name]
	  ,[Contact Name]
	  ,[Address line 1]
	  ,[Address line 2]
	  ,[City]
	  ,[Zip code]
	  ,[State]
	  ,[Country]
  FROM [Reporting].[AccountProfile]
ORDER BY [Active Customers] DESC


END

GO

