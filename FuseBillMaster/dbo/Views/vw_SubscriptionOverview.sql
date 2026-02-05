CREATE   VIEW [dbo].[vw_SubscriptionOverview]
AS
with LatestBillingPeriod as
(
SELECT Max(bp.Id) as Id, s.Id as SubscriptionId  
FROM BillingPeriod bp
INNER JOIN BillingPeriodDefinition bpd ON bpd.Id = bp.BillingPeriodDefinitionId
INNER JOIN Subscription s ON bpd.Id = s.BillingPeriodDefinitionId
WHERE bp.PeriodStatusId = 1 
GROUP BY s.Id
)
SELECT s.Id, s.AccountId, s.CustomerId, s.PlanCode as Code, s.CreatedTimestamp, s.ProvisionedTimestamp, s.ActivationTimestamp, 
s.StatusId, s.IntervalId as Interval, s.NumberOfIntervals, CASE WHEN afc.MrrDisplayTypeId = 1 THEN s.MonthlyRecurringRevenue ELSE s.CurrentMrr END as MonthlyRecurringRevenue, 
CASE WHEN s.StatusId = 2 OR s.StatusId = 6 THEN sp.RechargeDate ELSE null END as EndDate, 
sp.PeriodStatusId, CASE WHEN afc.MrrDisplayTypeId = 1 THEN s.NetMRR ELSE s.CurrentNetMrr END as NetMRR
FROM     
                  dbo.Subscription AS s 
                             left join LatestBillingPeriod lsp on s.id = lsp.SubscriptionId 
                             left join   dbo.BillingPeriod AS sp on lsp.id = sp.Id  
				INNER JOIN AccountFeatureConfiguration afc ON afc.Id = s.AccountId

GO

