--Stopgap
CREATE   PROC [dbo].[usp_GetRenewableInvoiceAccounts]
@RunDateTime Datetime = NULL
AS
set transaction isolation level snapshot
set nocount on

BEGIN TRY
if @RunDateTime is null 
    set @RunDateTime = GETUTCDATE()

DECLARE @CutoffDate DATETIME = DATEADD(YEAR, -1, @RunDateTime)

SELECT 
       Id
       ,StandardName
       ,utcDate.[UTCDateTime] as UtcPeriodEndDateTime
INTO #ModifiedEndTimestamp
FROM Lookup.Timezone
OUTER APPLY Timezone.tvf_GetTimezoneTime(Id, @RunDateTime) t
OUTER APPLY Timezone.tvf_GetUTCTime(Id, DATEADD(DAY, 1, t.TimezoneDate), DEFAULT, DEFAULT) utcDate

SELECT
       ps.InvoiceId as InvoiceId, ps.id as PaymentScheduleId, ps.DueDate
INTO    #tmp2
FROM  PaymentSchedule ps 
		WHERE 
		--Do not have account timezone at this point but due within 48 hours of now should
		--catch every invoice that will be due today in the account timezone
		ps.DueDate < DATEADD(DAY,2,@RunDateTime)
		AND ps.LastJournalTimestamp >= @CutoffDate
		AND  ps.StatusId in (1,2)
GROUP BY ps.InvoiceId, ps.id, ps.DueDate    

CREATE INDEX idx1 ON #tmp2(InvoiceId)

SELECT  i.AccountId as Id
FROM    #tmp2 a
        inner join invoice i on a.InvoiceId = i.Id
        inner join AccountPreference ap on i.AccountId = ap.Id
       inner join #ModifiedEndTimestamp MED on ap.TimezoneId = MED.Id
       INNER JOIN Account aa ON i.AccountId = aa.Id
       where aa.IncludeInAutomatedProcesses = 1 and 
			--Filtering with account timezone so we can get rid of the excess schedules from #tmp2
            a.DueDate < MED.UtcPeriodEndDateTime
			and i.EffectiveTimestamp >= @CutoffDate
GROUP BY 
        i.AccountId

DROP TABLE #ModifiedEndTimestamp
DROP TABLE #tmp2
   
SET NOCOUNT OFF
SELECT 0, @RunDateTime

END TRY

BEGIN CATCH
Select 1, @RunDateTime
END CATCH
SET NOCOUNT OFF

GO

