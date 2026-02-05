CREATE FUNCTION [dbo].[SubscriptionLevelCollection]
(	
	@AccountId as bigint,
	@TimezoneId as int
)
RETURNS TABLE 
AS
RETURN 
(

	SELECT s.Id as [Subscription Id],
			   COALESCE(so.Name, s.PlanName) as [Subscription Name],
			   COALESCE(COALESCE(so.Description, s.PlanDescription), '') as [Subscription Description], 
			   COALESCE(s.Reference, '') as [Subscription Reference],
			   lss.Name as [Subscription Status],
			   COALESCE(CONVERT(varchar(20),convert(datetime,dbo.fn_ConvertDateTimeToSmallDateTimeWithTimezone(s.[ContractStartTimestamp],@TimezoneId )), 120), '') as [Contract Start Date],
			   COALESCE(CONVERT(varchar(20),convert(datetime,dbo.fn_ConvertDateTimeToSmallDateTimeWithTimezone(s.[ContractEndTimestamp],@TimezoneId )), 120), '') as [Contract End Date],
 			ISNULL(CONVERT(varchar, s.RemainingInterval), '') as [Subscription Expiry Periods],
 			ISNULL(CONVERT(varchar, s.RemainingIntervalPushOut), '') as [Subscription Expiry Renewal Periods],
			   CASE WHEN afc.MrrDisplayTypeId = 1 THEN s.MonthlyRecurringRevenue ELSE s.CurrentMrr END as [Subscription Gross MRR],
			   CASE WHEN afc.MrrDisplayTypeId = 1 THEN s.NetMrr ELSE s.CurrentNetMrr END as [Subscription Net MRR]
    FROM Subscription s
			  INNER JOIN Customer c on c.Id = s.CustomerId and c.AccountId = @AccountId
			  INNER JOIN AccountFeatureConfiguration afc ON afc.Id = c.AccountId 
              LEFT JOIN SubscriptionOverride so ON s.Id = so.Id    
			  left join Lookup.SubscriptionStatus lss on lss.Id = s.StatusId
	     
)

GO

