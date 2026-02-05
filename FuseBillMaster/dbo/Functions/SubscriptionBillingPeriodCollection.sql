CREATE FUNCTION [dbo].[SubscriptionBillingPeriodCollection]
(	
	@AccountId as bigint,
	@TimezoneId as int
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT 	s.Id as XXXSubscriptionId, bpi.Name as [Billing Period Cycle],
			   bpt.Name as [Billing Period Type],
			   bpd.InvoiceDay as [Billing Period Invoice Day],
			   ISNULL(CONVERT(varchar,bpd.InvoiceMonth), '') as [Billing Period Invoice Month],
			   dbo.fn_ConvertDateTimeToSmallDateTimeWithTimezone(bp.CreatedTimeStamp,@TimezoneId ) as [Billing Period Created],
			   dbo.fn_ConvertDateTimeToSmallDateTimeWithTimezone(bp.StartDate,@TimezoneId ) as [Billing Period Current Interval Start Date],
			   dbo.fn_ConvertDateTimeToSmallDateTimeWithTimezone(bp.EndDate,@TimezoneId ) as [Billing Period Current Interval End Date]
    FROM Subscription s
			INNER JOIN Customer c on c.Id = s.CustomerId and c.AccountId = @AccountId
			  INNER JOIN BillingPeriodDefinition bpd ON bpd.Id = s.BillingPeriodDefinitionId
			  INNER JOIN BillingPeriod bp ON bpd.Id = bp.BillingPeriodDefinitionId AND bp.PeriodStatusId = 1
			  left join Lookup.Interval bpi on bpd.IntervalId = bpi.Id  
			  left join Lookup.BillingPeriodType bpt on bpt.Id = bpd.BillingPeriodTypeId		  

        
)

GO

