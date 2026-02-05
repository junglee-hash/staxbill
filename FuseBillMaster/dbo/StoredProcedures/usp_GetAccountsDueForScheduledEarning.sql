CREATE   Procedure [dbo].[usp_GetAccountsDueForScheduledEarning]
	@RunDateTime datetime = null
AS

if @RunDateTime is null
	set @RunDateTime = GETUTCDATE()

set nocount on
		
SELECT 
       Id
       ,StandardName
	   ,utcDate.UTCDateTime as UtcPeriodEndDateTime
INTO #ModifiedEndTimestamp
FROM Lookup.Timezone
OUTER APPLY Timezone.tvf_GetTimezoneTime(Id, @RunDateTime) t
OUTER APPLY Timezone.tvf_GetUTCTime(Id, DATEADD(DAY, 1, t.TimezoneDate), DEFAULT, DEFAULT) utcDate


select c.AccountId
from EarningSchedule es
inner join Charge ch ON ch.Id = es.ChargeId
inner join Invoice i ON i.Id = ch.InvoiceId
inner join Customer c ON c.Id = i.CustomerId and c.StatusId <> 3
inner join AccountPreference ap on c.AccountId = ap.Id
inner join #ModifiedEndTimestamp MED on ap.TimezoneId = MED.Id 
INNER JOIN Account a ON a.Id = c.AccountId
WHERE (a.IncludeInAutomatedProcesses = 1 OR a.ProcessEarningRegardless = 1)
AND es.ScheduledTimestamp IS NOT NULL
AND es.ScheduledTimestamp < MED.UtcPeriodEndDateTime
group by c.AccountId

set nocount off

GO

