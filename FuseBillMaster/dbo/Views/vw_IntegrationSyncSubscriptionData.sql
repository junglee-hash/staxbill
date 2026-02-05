CREATE VIEW [dbo].[vw_IntegrationSyncSubscriptionData]
AS
WITH BillingPeriods AS (SELECT        MAX(bp.Id) AS BillingPeriodId, s.Id as SubscriptionId
                                                                  FROM            dbo.BillingPeriod bp
																  inner join BillingPeriodDefinition bpd on bpd.Id = bp.BillingPeriodDefinitionId
																  inner join Subscription s on bpd.Id = s.BillingPeriodDefinitionId
																  WHERE bp.PeriodStatusId = 1
                                                                  GROUP BY s.Id)
    SELECT   DISTINCT     TOP (100) PERCENT sfbr.IntegrationSynchBatchId as BatchId, s.SalesforceId, cus.SalesforceId AS AccountSalesforceId,
	s.NetsuiteId, cus.NetsuiteId as CustomerNetsuiteId,
	 s.ActivationTimestamp, s.Amount, 
                              s.CreatedTimestamp, s.CustomerId, 
							  [dbo].[fn_GetFormattedFrequency](inr.Name, s.NumberOfIntervals) AS Frequency, 
							  s.Id, 
							  CASE WHEN afc.MrrDisplayTypeId = 1 THEN s.MonthlyRecurringRevenue ELSE s.CurrentMrr END AS MonthlyRecurringRevenue,
							  CASE WHEN afc.MrrDisplayTypeId = 1 THEN s.NetMRR ELSE s.CurrentNetMrr END AS NetMrr ,
							  sp.EndDate AS NextPeriodStartDate, 
							  s.PlanCode as Code, 
                              ISNULL(soverride.Description, s.PlanDescription) AS Description, ISNULL(soverride.Name, s.PlanName) AS Name, 
							  ISNULL(soverride.Name, s.PlanName) AS SubscriptionName, 
							  s.ProvisionedTimestamp, s.Reference, sstatus.Name AS Status, 
                              s.ScheduledActivationTimestamp, s.RemainingInterval, cus.AccountId
     FROM            dbo.Subscription s INNER JOIN
                              dbo.IntegrationSynchBatchRecord AS sfbr ON sfbr.EntityId = s.Id INNER JOIN
                              dbo.IntegrationSynchBatch AS sfb ON sfbr.IntegrationSynchBatchId = sfb.Id INNER JOIN
                              dbo.Customer AS cus ON cus.Id = s.CustomerId INNER JOIN
							  dbo.AccountFeatureConfiguration AS afc ON afc.Id = cus.AccountId LEFT OUTER JOIN
                              dbo.SubscriptionOverride AS soverride ON soverride.Id = s.Id LEFT OUTER JOIN
                              BillingPeriods AS sps ON s.Id = sps.SubscriptionId LEFT OUTER JOIN
                              dbo.BillingPeriod AS sp ON sp.Id = sps.BillingPeriodId LEFT OUTER JOIN
                              Lookup.Interval AS inr ON s.IntervalId = inr.Id LEFT OUTER JOIN
                              Lookup.SubscriptionStatus AS sstatus ON sstatus.Id = s.StatusId
     WHERE        (sfbr.EntityTypeId = 7) AND (sfb.StatusId NOT IN (4, 5)) ORDER BY s.Id

GO

