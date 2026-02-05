CREATE   procedure [dbo].[usp_GetDueInvoicesForEmailReminder]
@RunDateTime Datetime = NULL
AS

set nocount on
BEGIN TRY
if @RunDateTime is null 
       set @RunDateTime = GETUTCDATE()
--; WITH ModifiedEndTimestamp as
--(
--SELECT 
--       Id
--       ,StandardName
--       , DATEADD(Day,1,dbo.fn_GetUtcTime(CONVERT(Date,dbo.fn_GetTimezoneTime(@RunDateTime,Id)),Id)) as UtcPeriodEndDateTime

--FROM
--       Lookup.Timezone
--), 

create table #ModifiedEndTimestamp
(
Id bigint
,StandardName varchar (200)
, UtcPeriodEndDateTime datetime not null
)
insert into #ModifiedEndTimestamp

SELECT 
       Id
       ,StandardName
       , DATEADD(Day,1,dbo.fn_GetUtcTime(CONVERT(Date,dbo.fn_GetTimezoneTime(@RunDateTime,Id)),Id)) as UtcPeriodEndDateTime

FROM
       Lookup.Timezone

SELECT
       i.Id, ps.Id as PaymentScheduleId, i.AccountId, t.Name, MED.UtcPeriodEndDateTime
FROM Invoice i
		inner join Account a ON a.Id = i.AccountId
              inner join PaymentSchedule ps ON ps.InvoiceId = i.Id AND ps.IsDefault = 0
              inner join PaymentScheduleJournal psj ON ps.Id = psj.PaymentScheduleId and psj.StatusId in (1,2) AND psj.IsActive = 1 
       inner join customer c on c.Id = i.CustomerId and c.StatusId in (2,5) -- active and suspended
	   inner join CustomerBillingSetting cbs on i.CustomerId = cbs.Id
       inner join Lookup.Term t ON t.Id = COALESCE(i.TermId, cbs.TermId)
       inner join AccountPreference ap on i.AccountId = ap.Id
       inner join #ModifiedEndTimestamp MED on ap.TimezoneId = MED.Id
WHERE
       DATEADD(Day, t.DaysOffset *-1, psj.DueDate) < MED.UtcPeriodEndDateTime
	   and a.IncludeInAutomatedProcesses = 1
       and i.CustomerId NOT IN 
		(SELECT CustomerId FROM CustomerEmailControl WHERE CustomerId = i.CustomerId AND EmailKey = 'due_' + CAST(i.Id as varchar(10)) + '_' +  + CAST(ps.Id as varchar(10)) + '_' + CAST(t.Name as varchar(10)))
       
SET NOCOUNT OFF
SELECT 0, @RunDateTime

END TRY

BEGIN CATCH
Select 1, @RunDateTime
END CATCH
SET NOCOUNT OFF

GO

