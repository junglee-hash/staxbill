CREATE FUNCTION [dbo].[SubscriptionTimingCollection]
(	
	@AccountId as bigint,
	@TimezoneId as int,
	@EndDate as datetime
)
RETURNS TABLE 
AS
RETURN 
(
	WITH 
	MostRecentJournal AS (
       SELECT MAX(j.Id) as Id, SubscriptionId
       FROM SubscriptionStatusJournal j
       WHERE j.CreatedTimestamp <= @EndDate
       GROUP BY SubscriptionId)

	SELECT 	s.Id as XXXSubscriptionId,
				dbo.fn_ConvertDateTimeToSmallDateTimeWithTimezone(s.CreatedTimestamp,@TimezoneId )  as [Subscription Created Timestamp],
			   COALESCE(CONVERT(varchar(20),convert(datetime,dbo.fn_ConvertDateTimeToSmallDateTimeWithTimezone(s.ActivationTimestamp, @TimezoneId)), 120), '') as [Subscription Activation Timestamp],
			   COALESCE(CONVERT(varchar(20),convert(datetime,dbo.fn_ConvertDateTimeToSmallDateTimeWithTimezone(s.CancellationTimestamp,@TimezoneId )), 120), '') as [Subscription Cancellation Timestamp],
			   COALESCE(CONVERT(varchar(20),convert(datetime,dbo.fn_ConvertDateTimeToSmallDateTimeWithTimezone(s.ScheduledActivationTimestamp,@TimezoneId )), 120), '') as [Scheduled Activation Timestamp],
			   COALESCE(CONVERT(varchar(20),convert(datetime,dbo.fn_ConvertDateTimeToSmallDateTimeWithTimezone(s.ProvisionedTimestamp,@TimezoneId )), 120), '') as [Provisioned Timestamp],
			   COALESCE(CONVERT(varchar(20),convert(datetime,dbo.fn_ConvertDateTimeToSmallDateTimeWithTimezone(s.ExpiredTimestamp,@TimezoneId )), 120), '') as [Expired Timestamp],
			   case when ssj.StatusId = 6 then COALESCE(CONVERT(varchar(20),convert(datetime,dbo.fn_ConvertDateTimeToSmallDateTimeWithTimezone(ssj.CreatedTimestamp,@TimezoneId )), 120), '') else '' end as [Suspended Timestamp], 			   
			   case when (ssj.StatusId = 2 AND bp.EndDate is not null AND s.RemainingInterval is not null) 
				THEN COALESCE(CONVERT(varchar(20),convert(datetime,dbo.fn_ConvertDateTimeToSmallDateTimeWithTimezone(dbo.fn_CalculateExpiringDate(bp.EndDate,s.NumberOfIntervals,s.IntervalId,s.RemainingInterval),@TimezoneId )), 120), '')
				ELSE '' 
				END as [Expiring Timestamp],
				COALESCE(CONVERT(varchar(20),convert(datetime,dbo.fn_ConvertDateTimeToSmallDateTimeWithTimezone(s.MigratedTimestamp,@TimezoneId )), 120), '') as [Migrated Timestamp],
			   CASE WHEN s.RemainingInterval = 0 THEN null ELSE dbo.fn_ConvertDateTimeToSmallDateTimeWithTimezone(bp.EndDate,@TimezoneId ) END as [Next Recharge Date]		   
    FROM Subscription s
			  INNER JOIN Customer c on c.Id = s.CustomerId and c.AccountId = @AccountId
              INNER JOIN MostRecentJournal mrj ON s.Id = mrj.SubscriptionId
              INNER JOIN SubscriptionStatusJournal ssj ON ssj.Id = mrj.Id
			  INNER JOIN BillingPeriodDefinition bpd ON bpd.Id = s.BillingPeriodDefinitionId
			  INNER JOIN BillingPeriod bp ON bpd.Id = bp.BillingPeriodDefinitionId AND bp.PeriodStatusId = 1

	      
)

GO

