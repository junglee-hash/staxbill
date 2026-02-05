CREATE   procedure [dbo].[usp_GetAccountForTextMessaging]

@RunDateTime Datetime = NULL
AS
set transaction isolation level snapshot
set nocount on

if @RunDateTime is null 
       set @RunDateTime = GETUTCDATE()

create  table #AccountTimezoneDates
(
	AccountId bigint
	, Timezone varchar(50)
	, CurrentDateInAccountTimezone date
	, UtcStartOfSendingPeriod datetime
	, UtcEndOfSendingPeriod datetime
)

INSERT INTO #AccountTimezoneDates
SELECT ap.Id as AccountId
	, tz.ClrId as Timezone
	, t.TimezoneDate
	, utcStart.UTCDateTime as UtcStartOfSendingPeriod
	, utcEnd.UTCDateTime as UtcEndOfSendingPeriod
FROM AccountPreference ap
INNER JOIN Account a ON a.Id = ap.Id
INNER JOIN Lookup.Timezone tz ON ap.TimezoneId = tz.Id	
OUTER APPLY Timezone.tvf_GetTimezoneTime(tz.Id, @RunDateTime) t
OUTER APPLY Timezone.tvf_GetUTCTime(tz.Id, DATEADD(HOUR, 7, CONVERT(datetime, t.TimezoneDate)), DEFAULT, DEFAULT) utcStart
OUTER APPLY Timezone.tvf_GetUTCTime(tz.Id, DATEADD(HOUR, 22, CONVERT(datetime, t.TimezoneDate)), DEFAULT, DEFAULT) utcEnd
WHERE
	a.IncludeInAutomatedProcesses = 1

SELECT DISTINCT atd.AccountId
FROM #AccountTimezoneDates atd
INNER JOIN Customer c ON c.AccountId = atd.AccountId
INNER JOIN CustomerTextLog ctl ON ctl.CustomerId = c.Id
WHERE ctl.TxtStatusId = 1 AND ctl.SentTimestamp IS NULL
	AND @RunDateTime >= atd.UtcStartOfSendingPeriod
	AND @RunDateTime < atd.UtcEndOfSendingPeriod

drop table #AccountTimezoneDates

SET NOCOUNT OFF

GO

