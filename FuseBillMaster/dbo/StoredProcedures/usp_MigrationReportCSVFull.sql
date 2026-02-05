CREATE PROCEDURE [dbo].[usp_MigrationReportCSVFull]
		@AccountId bigint
	,@StartDate datetime
	,@EndDate datetime
	,@SourcePlanCode varchar(255) 
	,@DestinationPlanCode varchar(255)
	,@SourcePlanFrequency varchar(255)
	,@DestinationPlanFrequency varchar(255)
	,@MigrationType varchar(1000)
AS
BEGIN
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT

--Temp table to customer details
SELECT * INTO #CustomerData
FROM FullCustomerDataByAccount(@AccountId,NULL,@EndDate)

declare @TimezoneId int
declare @MrrType int

select @TimezoneId = TimezoneId from AccountPreference where Id = @AccountId 

--1 is committed mrr
--2 is current mrr
select @MrrType = MrrDisplayTypeId from AccountFeatureConfiguration where Id = @AccountId

declare @MigrationTypes Table
(
	MigrationTypeValue varchar(255)
)
insert into @MigrationTypes
select Data from dbo.Split(@MigrationType,'|')

CREATE TABLE #MigrationTable 
(
	MigrationTimestamp datetime,
	MigrationType varchar(255),
	SourceSubscriptionId bigint,
	SourceSubscriptionName varchar(255),
	SourceSubscriptionDescription nvarchar(1000),
	SourcePlanName varchar(255),
	SourcePlanCode varchar(255),
	SourceSubscriptionInterval varchar(255),
	SourceSubscriptionNumberOfIntervals int,
	SourceSubscriptionNetMrr money,
	DestinationSubscriptionId bigint,
	DestinationSubscriptionName varchar(255),
	DestinationSubscriptionDescription nvarchar(1000),
	DestinationPlanName varchar(255),
	DestinationPlanCode varchar(255),
	DestinationSubscriptionInterval varchar(255),
	DestinationSubscriptionNumberOfIntervals int,
	DestinationSubscriptionNetMrr money,
	FusebillId bigint,
	RelationshipName nvarchar(255),
	RelationshipDescription nvarchar(1000),
)
insert into #MigrationTable
Select 
	dbo.fn_GetTimezoneTime(migration.EffectiveTimestamp,@TimezoneId ),
	rmt.Name,
	sourceSub.Id,
	isnull(sourceSubO.Name,sourceSub.PlanName),
	isnull(sourceSubO.[Description],sourceSub.PlanDescription),
	sourceSub.PlanName,
	sourceSub.PlanCode,
	sourceFreqInterval.Name, 
	sourceFreq.NumberOfIntervals,
	Case
		when @MrrType = 1 --committed mrr
		then migration.SourceCommittedNetMrr
		else migration.SourceCurrentNetMrr
	end,
	destinationSub.Id,
	isnull(destinationSubO.Name,destinationSub.PlanName),
	isnull(destinationSubO.[Description],destinationSub.PlanDescription),
	destinationSub.PlanName,
	destinationSub.PlanCode,
	destinationFreqInterval.Name, 
	destFreq.NumberOfIntervals,
	Case
		when @MrrType = 1 --committed mrr
		then migration.DestinationCommittedNetMrr
		else migration.DestinationCurrentNetMrr
	end,
	migration.FusebillId,
	pfr.[Name],
	pfr.[Description]
from 
	[dbo].[Migration] migration
	inner join [dbo].[PlanFamilyRelationship] as pfr on pfr.Id = migration.RelationshipId
	inner join [dbo].[PlanFamily] as pf on pf.Id = pfr.PlanFamilyId
	inner join [dbo].[Customer] as cust on cust.Id = migration.FusebillId
	inner join [dbo].[Subscription] as sourceSub on sourceSub.Id = migration.SourceSubscriptionId
	left outer join [dbo].[SubscriptionOverride] as sourceSubO on sourceSubO.Id = sourceSub.Id
	inner join [dbo].[Subscription] as destinationSub on destinationSub.Id = migration.DestinationSubscriptionId
	left outer join [dbo].[SubscriptionOverride] as destinationSubO on destinationSubO.Id = destinationSub.Id
	inner join [dbo].[PlanFrequency] as sourceFreq on sourceFreq.Id = migration.SourcePlanFrequencyId
	inner join [dbo].[PlanFrequency] as destFreq on destFreq.Id = migration.DestinationPlanFrequencyId
	inner join [Lookup].[RelationshipMigrationType] as rmt on rmt.Id = migration.RelationshipMigrationTypeId
	inner join [Lookup].[Interval] as sourceFreqInterval on sourceFreqInterval.Id = sourceFreq.Interval
	inner join [Lookup].[Interval] as destinationFreqInterval on destinationFreqInterval.Id = destFreq.Interval
Where
	migration.EffectiveTimestamp >= @StartDate and migration.EffectiveTimestamp <= @EndDate and pf.AccountId = @AccountId

select 
	migration.MigrationTimestamp as [Migration Timestamp],
	migration.MigrationType as [Migration Type],
	isnull(migration.RelationshipName, '') as [Relationship Name],
	isnull(migration.RelationshipDescription, '') as [Relationship Description],
	migration.SourceSubscriptionId as [Source Subscription ID],
	migration.SourceSubscriptionName as [Source Subscription Name],
	migration.SourceSubscriptionDescription as [Source Subscription Description],
	migration.SourcePlanName as [Source Plan Name],
	migration.SourcePlanCode as [Source Plan Code],
	migration.SourceSubscriptionInterval as [Source Subscription Interval],
	migration.SourceSubscriptionNumberOfIntervals as [Source Subscription Number Of Intervals],
	migration.SourceSubscriptionNetMrr as [Source Subscription Net Mrr (At Time of Migration)],
	isnull(sourceSub.PlanReference, '') as [Source Subscription Reference],
	dbo.fn_GetTimezoneTime(sourceSub.CreatedTimestamp,@TimezoneId ) as [Source Subscription Created Date],
	dbo.fn_GetTimezoneTime(sourceSub.ActivationTimestamp,@TimezoneId ) as [Source Subscription Activation Date],
	migration.DestinationSubscriptionId as [Destination Subscription ID],
	migration.DestinationSubscriptionName as [Destination Subscription Name],
	migration.DestinationSubscriptionDescription as [Destination Subscription Description],
	migration.DestinationPlanName as [Destination Plan Name],
	migration.DestinationPlanCode as [Destination Plan Code],
	migration.DestinationSubscriptionInterval as [Destination Subscription Interval],
	migration.DestinationSubscriptionNumberOfIntervals as [Destination Subscription Number Of Intervals],
	migration.DestinationSubscriptionNetMrr as [Destination Subscription Net Mrr (At Time of Migration)],
	isnull(DestinationSub.PlanReference, '') as [Destination Subscription Reference],
	dbo.fn_GetTimezoneTime(DestinationSub.CreatedTimestamp,@TimezoneId ) as [Destination Subscription Created Date],
	dbo.fn_GetTimezoneTime(DestinationSub.ActivationTimestamp,@TimezoneId ) as [Destination Subscription Activation Date],
	Customer.* 
from 
	#MigrationTable migration
	inner join [dbo].[Subscription] as sourceSub on sourceSub.Id = migration.SourceSubscriptionId
	inner join [dbo].[Subscription] as destinationSub on destinationSub.Id = migration.DestinationSubscriptionId
	INNER JOIN #CustomerData Customer ON Customer.[Fusebill ID] = migration.FusebillId
where
	SourcePlanCode = (Case
								when @SourcePlanCode != 'Any'
								then @SourcePlanCode
								else SourcePlanCode
								end)
	and DestinationPlanCode = (Case
								when @DestinationPlanCode != 'Any'
								then @DestinationPlanCode
								else DestinationPlanCode
								end)
	and [dbo].[fn_GetFormattedFrequency](SourceSubscriptionInterval, SourceSubscriptionNumberOfIntervals) = (Case
								when @SourcePlanFrequency != 'All'
								then @SourcePlanFrequency
								else [dbo].[fn_GetFormattedFrequency](SourceSubscriptionInterval, SourceSubscriptionNumberOfIntervals)
								end)
	and [dbo].[fn_GetFormattedFrequency](DestinationSubscriptionInterval, DestinationSubscriptionNumberOfIntervals) = (Case
								when @DestinationPlanFrequency != 'All'
								then @DestinationPlanFrequency
								else [dbo].[fn_GetFormattedFrequency](DestinationSubscriptionInterval, DestinationSubscriptionNumberOfIntervals)
								end)
	and MigrationType in (Case
								when @MigrationType != 'All'
								then (select * from @MigrationTypes where MigrationTypeValue = MigrationType)
								else MigrationType
								end)
	DROP TABLE #MigrationTable
	DROP TABLE #CustomerData
END

GO

