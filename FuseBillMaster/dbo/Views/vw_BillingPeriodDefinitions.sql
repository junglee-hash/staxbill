
CREATE VIEW [dbo].[vw_BillingPeriodDefinitions]
AS
with LatestBillingPeriod as
(
SELECT bp.StartDate, bp.EndDate, bp.RechargeDate, bp.BillingPeriodDefinitionId
FROM BillingPeriod bp
INNER JOIN BillingPeriodDefinition bpd ON bpd.Id = bp.BillingPeriodDefinitionId
WHERE bp.PeriodStatusId = 1 
)


SELECT bpd.[Id]
	  ,c.AccountId
	  ,(select count(*) from Subscription s where s.BillingPeriodDefinitionId = bpd.id AND s.IsDeleted = 0) as [NumberOfSubscriptions]
      ,bpd.[CustomerId]
      ,bpd.[IntervalId]
      ,bpd.[NumberOfIntervals]
      ,bpd.[InvoiceDay]
	  ,bpd.[InvoiceWeekday]
      ,bpd.[BillingPeriodTypeId]
      ,bpd.[InvoiceMonth]
	  ,bpd.[InvoiceInAdvance]
	  ,(select count(*) from LatestBillingPeriod lbp where lbp.BillingPeriodDefinitionId = bpd.Id) as [NumberOfBillingPeriods]
	  ,(select top 1 lbp.StartDate from LatestBillingPeriod lbp where lbp.BillingPeriodDefinitionId = bpd.Id order by lbp.StartDate desc) as [MostRecentBillingPeriodStartDate]
	  ,(select top 1 lbp.EndDate from LatestBillingPeriod lbp where lbp.BillingPeriodDefinitionId = bpd.Id order by lbp.StartDate desc) as [MostRecentBillingPeriodEndDate]
	  ,(select top 1 lbp.RechargeDate from LatestBillingPeriod lbp where lbp.BillingPeriodDefinitionId = bpd.Id order by lbp.StartDate desc) as [NextRechargeDate]
	  ,CAST (CASE
		-- want to include ALL subscriptions for can delete, even soft delete
		WHEN EXISTS(select 1 from Subscription s where s.BillingPeriodDefinitionId = bpd.id) THEN
			0
		WHEN EXISTS(select 1 from DraftSubscriptionProductCharge dc
						INNER JOIN BillingPeriod bp ON dc.BillingPeriodId = bp.Id where bp.BillingPeriodDefinitionId = bpd.id) THEN
			0
		WHEN EXISTS(select 1 from SubscriptionProductCharge sc
						INNER JOIN BillingPeriod bp ON sc.BillingPeriodId = bp.Id where bp.BillingPeriodDefinitionId = bpd.id) THEN
			0
		ELSE
			1
		END  AS BIT) AS CanDelete
		,bpd.PoNumber
  FROM [dbo].[BillingPeriodDefinition] bpd
  INNER JOIN dbo.Customer c ON c.Id = bpd.CustomerId

GO

