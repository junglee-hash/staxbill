CREATE   VIEW [dbo].[vw_SubscriptionSummary]
AS
SELECT
	COALESCE (dbo.SubscriptionOverride.Name, s.PlanName) AS Name, 
	COALESCE (dbo.SubscriptionOverride.Description, s.PlanDescription) AS Description, 
	s.StatusId, 
	s.Reference, 
	s.IntervalId AS Interval, 
	s.NumberOfIntervals AS NumberOfInterval,
	s.Id, 
	s.PlanId,
	s.PlanCode, 
	c.Id AS CustomerId,
	s.AccountId, 
    CASE WHEN afc.MrrDisplayTypeId = 1 THEN s.MonthlyRecurringRevenue ELSE s.CurrentMrr END AS MonthlyRecurringRevenue, 
	s.CreatedTimestamp, 
	s.ModifiedTimestamp,
	s.CancellationTimestamp, 
	s.ScheduledActivationTimestamp, 	
	s.BillingPeriodDefinitionId,  
	s.ActivationTimestamp AS ActivatedTimestamp,		 
	s.ProvisionedTimestamp,
	sp.EndDate AS NextPeriodStartDate,
	s.RemainingInterval,
	s.ContractStartTimestamp,
	s.ContractEndTimestamp,
	CASE WHEN s.StatusId = 6 THEN csj.CreatedTimestamp ELSE NULL END AS SuspendedTimestamp,
	CASE WHEN s.StatusId = 2 OR s.StatusId = 4 THEN 
	CASE 
		WHEN sp.StartDate < s.ActivationTimestamp 
			THEN s.ActivationTimestamp 
			ELSE sp.StartDate 
		END 
	ELSE NULL END AS LastBillingDate, 
	CASE WHEN s.StatusId = 2 OR s.StatusId = 6 THEN sp.RechargeDate ELSE NULL END AS NextBillingDate, 
	CASE WHEN s.StatusId = 5 THEN s.ExpiredTimestamp ELSE
		CASE WHEN s.StatusId != 1 AND s.RemainingInterval IS NOT NULL AND DATEPART(YEAR, sp.RechargeDate) != 9999 THEN 
			CASE WHEN s.IntervalId = 1 THEN 
				DATEADD(DAY, s.InvoiceInAdvance * -1, DATEADD(DAY, s.RemainingInterval * s.NumberOfIntervals, sp.EndDate)) 
			WHEN s.IntervalId = 2 THEN 
				DATEADD(DAY, s.InvoiceInAdvance * -1, DATEADD(WEEK, s.RemainingInterval * s.NumberOfIntervals, sp.EndDate)) 
			WHEN s.IntervalId = 3 THEN 
				DATEADD(DAY, s.InvoiceInAdvance * -1, DATEADD(MONTH, s.RemainingInterval * s.NumberOfIntervals, sp.EndDate)) 
			WHEN s.IntervalId = 4 THEN 
				DATEADD(DAY, s.InvoiceInAdvance * -1, DATEADD(QUARTER, s.RemainingInterval * s.NumberOfIntervals, sp.EndDate)) 
			WHEN s.IntervalId = 5 THEN 
				DATEADD(DAY, s.InvoiceInAdvance * -1, DATEADD(YEAR, s.RemainingInterval * s.NumberOfIntervals, sp.EndDate)) 
			END 
		ELSE 
			NULL 
		END 
	END AS ExpiryDate, 
	CASE WHEN afc.MrrDisplayTypeId = 1 THEN s.NetMRR ELSE s.CurrentNetMrr END AS NetMonthlyRecurringRevenue,
	s.MigratedTimestamp,
	CASE 
		WHEN s.StatusId = 2 AND pfp.Id IS NOT NULL 
		and (select count(*) as ActiveMigrations
			from Subscription sub
			join PlanFamilyRelationship pfr on pfr.SourcePlanFrequencyId = s.PlanFrequencyId
			where 
				sub.id = s.Id
				and pfr.PlanStatusId = 1) > 0 
		THEN 1 
		ELSE 0 
	END AS CanMigrate,
	CASE	 
		WHEN sm.Id IS NOT NULL AND sp.Id IS NOT NULL AND sm.MigrationTimingOptionId = 2 THEN sp.RechargeDate 
		WHEN sm.Id IS NOT NULL AND sm.MigrationTimingOptionId = 3 THEN sm.SpecifiedDate
		ELSE NULL 
	END AS ScheduledMigrationDate,
	c.FirstName AS CustomerFirstName,
	c.MiddleName AS CustomerMiddleName,
	c.LastName AS CustomerLastName,
	c.Suffix AS CustomerSuffix,
	c.PrimaryEmail as CustomerPrimaryEmail,
	[Lookup].[Title].Name AS CustomerTitle,
	c.Reference AS CustomerReference,
	c.ParentId AS CustomerParentId,
	c.IsParent as CustomerIsParent,
	Lookup.CustomerAccountStatus.Name AS AccountingStatus,
	Lookup.CustomerStatus.Name AS CustomerStatus,
	c.CompanyName AS CompanyName,
	c.CurrencyId AS Currency,
	s.IsDeleted,
	COALESCE(sp.CustomerId,s.CustomerId) as InvoiceOwnerCustomerId,
	s.GeotabDevicePlanId,
	COALESCE(CONVERT(VARCHAR,m.RelationshipId), CONVERT(VARCHAR,sm.PlanFamilyRelationshipId), '') AS RelationshipId,
	COALESCE(rmt.Name, rmtSm.Name, '') AS RelationshipMigrationType,
	CASE
		WHEN sm.Id is null and m.id is null THEN '' 
		ELSE COALESCE(s.PlanName, '')
	END AS MigrationSourcePlanName,
	CASE
		WHEN sm.Id is null and m.id is null THEN '' 
		ELSE COALESCE(s.PlanCode, '')
	END AS MigrationSourcePlanCode,
	COALESCE(sourceFreqInterval.[Name], sourceFreqIntervalSm.[Name], '') AS MigrationSourcePlanFrequency,
	COALESCE(sd.PlanName, p.Name, '') AS MigrationDestinationPlanName,
	COALESCE(sd.PlanCode, p.Code, '') AS MigrationDestinationPlanCode,
	COALESCE(destinationFreqInterval.Name, destinationFreqIntervalSm.Name, '') AS MigrationDestinationPlanFrequency,
	stc1.Id AS SalesTrackingCode1Id,
	stc1.Code AS SalesTrackingCode1Code,
	stc1.[Name] AS SalesTrackingCode1Name,
	stc2.Id AS SalesTrackingCode2Id,
	stc2.Code AS SalesTrackingCode2Code,
	stc2.[Name] AS SalesTrackingCode2Name,
	stc3.Id AS SalesTrackingCode3Id,
	stc3.Code AS SalesTrackingCode3Code,
	stc3.[Name] AS SalesTrackingCode3Name,
	stc4.Id AS SalesTrackingCode4Id,
	stc4.Code AS SalesTrackingCode4Code,
	stc4.[Name] AS SalesTrackingCode4Name,
	stc5.Id AS SalesTrackingCode5Id,
	stc5.Code AS SalesTrackingCode5Code,
	stc5.[Name] AS SalesTrackingCode5Name
FROM Subscription s 
INNER JOIN Customer c ON s.CustomerId = c.Id
INNER JOIN CustomerStatusJournal csj ON c.Id = csj.CustomerId AND csj.IsActive = 1 
INNER JOIN AccountFeatureConfiguration afc ON afc.Id = s.AccountId
INNER JOIN Lookup.CustomerAccountStatus ON c.AccountStatusId = Lookup.CustomerAccountStatus.Id
INNER JOIN Lookup.CustomerStatus ON c.StatusId = Lookup.CustomerStatus.Id
LEFT OUTER JOIN dbo.SubscriptionOverride ON s.Id = dbo.SubscriptionOverride.Id 
LEFT JOIN ScheduledMigration sm ON sm.Id = s.Id
LEFT JOIN PlanFamilyRelationship pfr ON pfr.Id = sm.PlanFamilyRelationshipId
LEFT JOIN Migration m ON m.SourceSubscriptionId = s.Id 
LEFT JOIN Subscription sd ON m.DestinationSubscriptionId = sd.Id
LEFT JOIN PlanFrequency sourceFreq on sourceFreq.Id = m.SourcePlanFrequencyId
LEFT JOIN PlanFrequency sourceFreqSm on sourceFreqSm.Id = pfr.SourcePlanFrequencyId
LEFT JOIN PlanFrequency destFreq on destFreq.Id = m.DestinationPlanFrequencyId
LEFT JOIN PlanFrequency destFreqSm on destFreqSm.Id = pfr.DestinationPlanFrequencyId
LEFT JOIN Lookup.RelationshipMigrationType rmt ON rmt.Id = m.RelationshipMigrationTypeId
LEFT JOIN Lookup.RelationshipMigrationType rmtSm ON rmtSm.Id = pfr.RelationshipMigrationTypeId
LEFT JOIN Lookup.Interval  sourceFreqInterval on sourceFreqInterval.Id = sourceFreq.Interval
LEFT JOIN Lookup.Interval  sourceFreqIntervalSm on sourceFreqIntervalSm.Id = sourceFreqSm.Interval
LEFT JOIN Lookup.Interval  destinationFreqInterval on destinationFreqInterval.Id = destFreq.Interval
LEFT JOIN Lookup.Interval  destinationFreqIntervalSm on destinationFreqIntervalSm.Id = destFreqSm.Interval
INNER JOIN dbo.CustomerReference AS cr ON cr.Id = c.Id 
LEFT JOIN SalesTrackingCode stc1 ON cr.SalesTrackingCode1Id = stc1.Id
LEFT JOIN SalesTrackingCode stc2 ON cr.SalesTrackingCode2Id = stc2.Id
LEFT JOIN SalesTrackingCode stc3 ON cr.SalesTrackingCode3Id = stc3.Id
LEFT JOIN SalesTrackingCode stc4 ON cr.SalesTrackingCode4Id = stc4.Id
LEFT JOIN SalesTrackingCode stc5 ON cr.SalesTrackingCode5Id = stc5.Id
LEFT JOIN PlanRevision pr ON pr.Id = destFreqSm.PlanRevisionId
LEFT JOIN [Plan] p ON p.Id = pr.PlanId
LEFT JOIN [Lookup].[Title] ON c.TitleId = [Lookup].[Title].Id
OUTER APPLY (
	SELECT TOP 1 bp.Id,EndDate,RechargeDate,StartDate, bpd.CustomerId
	FROM BillingPeriod bp
	INNER JOIN BillingPeriodDefinition bpd ON bpd.Id = bp.BillingPeriodDefinitionId
	WHERE bp.PeriodStatusId = 1 AND bpd.Id = s.BillingPeriodDefinitionId
	ORDER BY bp.Id DESC
	) sp

OUTER APPLY (
	SELECT TOP 1 pfp.Id
	FROM PlanFamilyPlan pfp
	WHERE pfp.PlanId = s.PlanId
	) pfp

GO

