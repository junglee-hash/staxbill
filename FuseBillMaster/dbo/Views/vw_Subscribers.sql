
CREATE VIEW [dbo].[vw_Subscribers]
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

    SELECT TOP (100) PERCENT 
	s.Id,
	dbo.Customer.Id as FusebillId,
	dbo.Customer.Reference as CustomerId, 
	dbo.Customer.TitleId, 
	dbo.Customer.FirstName, 
	dbo.Customer.MiddleName,
	dbo.Customer.LastName, 
	dbo.Customer.Suffix, 
	dbo.Customer.EffectiveTimestamp AS CustomerCreatedTimestamp, 
	dbo.Customer.AccountId, 
	dbo.Customer.PrimaryEmail, 
	dbo.Customer.NextBillingDate, 
	dbo.Customer.CompanyName, 
    dbo.Customer.StatusId AS CustomerStatusId, 
	cr.Reference1, 
	cr.Reference2, 
	cr.Reference3,
	Lookup.CustomerStatus.Name AS CustomerStatus,
	s.StatusId as SubscriptionStatusId,
	Lookup.SubscriptionStatus.Name as SubscriptionStatus,
	s.CreatedTimestamp AS SubscriptionCreatedTimestamp,
	CASE WHEN s.StatusId = 2 OR s.StatusId = 6 THEN sp.EndDate ELSE null END as NextRechargeDate, 
	sp.PeriodStatusId,
	s.IntervalId,
	s.NumberOfIntervals,
	s.PlanId,
	stc1.Id as [SalesTrackingCode1Id],
	stc1.Code as [SalesTrackingCode1Code],
	stc1.Name as [SalesTrackingCode1Name],
	stc2.Id as [SalesTrackingCode2Id],
	stc2.Code as [SalesTrackingCode2Code],
	stc2.Name as [SalesTrackingCode2Name],
	stc3.Id as [SalesTrackingCode3Id],
	stc3.Code as [SalesTrackingCode3Code],
	stc3.Name as [SalesTrackingCode3Name],
	stc4.Id as [SalesTrackingCode4Id],
	stc4.Code as [SalesTrackingCode4Code],
	stc4.Name as [SalesTrackingCode4Name],
	stc5.Id as [SalesTrackingCode5Id],
	stc5.Code as [SalesTrackingCode5Code],
	stc5.Name as [SalesTrackingCode5Name],
	s.IsDeleted
	FROM     dbo.Customer 					  
					  INNER JOIN Lookup.CustomerStatus ON dbo.Customer.StatusId = Lookup.CustomerStatus.Id 
					  INNER JOIN dbo.Subscription AS s ON s.CustomerId = dbo.Customer.Id
					  INNER JOIN Lookup.SubscriptionStatus ON s.StatusId =  Lookup.SubscriptionStatus.Id
					  left join LatestBillingPeriod lsp on s.id = lsp.SubscriptionId 
                      left join   dbo.BillingPeriod AS sp on lsp.id = sp.Id  
					  LEFT OUTER JOIN dbo.CustomerAcquisition AS ca ON ca.Id = dbo.Customer.Id 
					  LEFT OUTER JOIN dbo.CustomerReference AS cr ON cr.Id = dbo.Customer.Id 
					  left join SalesTrackingCode stc1
						on cr.SalesTrackingCode1Id = stc1.Id
						left join SalesTrackingCode stc2
						on cr.SalesTrackingCode2Id = stc2.Id
						left join SalesTrackingCode stc3
						on cr.SalesTrackingCode3Id = stc3.Id
						left join SalesTrackingCode stc4
						on cr.SalesTrackingCode4Id = stc4.Id
						left join SalesTrackingCode stc5
						on cr.SalesTrackingCode5Id = stc5.Id

GO

