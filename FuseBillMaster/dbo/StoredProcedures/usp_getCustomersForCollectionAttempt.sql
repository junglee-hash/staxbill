CREATE   procedure [dbo].[usp_getCustomersForCollectionAttempt]
--DECLARE
@UTCDateTime datetime = '2020-04-05 5:05AM'
as
If @UTCDateTime is NULL
       SET @UTCDateTime = GETUTCDATE()

create table #ModifiedRuntime
(
Id bigint
,StandardName varchar (200)
,UtcRuntime datetime
,CONSTRAINT [PK_#ModifiedRuntime] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
INSERT INTO #ModifiedRuntime
SELECT 
       Id
       ,StandardName
	   ,utcDate.UTCDateTime as UtcRuntime
FROM Lookup.Timezone
--OUTER APPLY Timezone.tvf_GetTimezoneTime(Id, @RunDateTime) t
OUTER APPLY Timezone.tvf_GetTimezoneTime(Id, @UTCDateTime) t
OUTER APPLY Timezone.tvf_GetUTCTime(Id, DATEADD(DAY, 1, t.TimezoneDate), DEFAULT, DEFAULT) utcDate


;with CurrentCollection
as
(

       SELECT
              csa.CustomerId
              ,max(DayAttempted) as DayAttempted
       FROM
              CollectionScheduleActivity csa
              inner join CustomerAccountStatusJournal casj
              on csa.CustomerId = casj.CustomerId 
			  and isactive = 1
			  and casj.EffectiveTimestamp < csa.CreatedTimestamp 
              AND casj.StatusId = 2 --PoorStanding
       GROUP BY 
              csa.CustomerId
       ) --CurrentCollection on CurrentCollection.CustomerId = casj.CustomerId            
SELECT
       c.Id
FROM
       Customer c
INNER JOIN Account a ON a.Id = c.AccountId
INNER JOIN
       CustomerAccountStatusJournal casj on c.Id = casj.CustomerId 
	   AND casj.IsActive = 1 --Current customer account status
       AND casj.StatusId = 2 --PoorStanding
INNER JOIN
       CustomerBillingSetting cbs on cbs.Id = c.Id and cbs.DunningExempt = 0
INNER JOIN
       AccountPreference ap on ap.Id = c.AccountId
INNER JOIN 
       #ModifiedRuntime MED on ap.TimezoneId = MED.Id
left join PaymentActivityJournal paj ON c.Id = paj.CustomerId AND paj.PaymentActivityStatusId = 3
left join CurrentCollection CurrentCollection on c.Id = CurrentCollection.CustomerId
INNER JOIN
       AccountCollectionSchedule acs on acs.AccountId = c.AccountId  
	   and acs.Day > isnull(CurrentCollection.DayAttempted, 0)
OUTER APPLY Timezone.tvf_GetTimezoneTime(MED.Id, casj.EffectiveTimestamp) t
OUTER APPLY Timezone.tvf_GetUTCTime(MED.Id, DATEADD(DAY, acs.Day, t.TimezoneDate), DEFAULT, DEFAULT) utcDate

	   
		-- get the date by converting to the account timezone
		-- add X to that date
		-- convert that date to UTC midnight for the account timezone
		--utcDate.UTCDateTime
		--dbo.fn_GetUtcTime(dateadd(day, acs.Day, t.TimezoneDate), MED.Id)
		
Inner join AccountBillingPreference abp
on c.AccountId = abp.Id 
WHERE
       coalesce(cbs.AutoCollect,abp.DefaultAutoCollect) = 1
	   AND c.StatusId = 2 --Active
	   AND paj.Id IS NULL -- No unknown payments
	    and MED.UtcRuntime > utcDate.UTCDateTime
		AND a.IncludeInAutomatedProcesses = 1
GROUP BY c.Id
ORDER BY c.Id

DROP TABLE #ModifiedRuntime

GO

