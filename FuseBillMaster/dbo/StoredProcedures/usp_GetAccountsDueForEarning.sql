CREATE   PROCEDURE [dbo].[usp_GetAccountsDueForEarning]
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

select ch.InvoiceId, cle.NextEarningTimestamp
INTO    #tmp1
from ChargeLastEarning cle
inner join Charge ch ON ch.Id = cle.Id
    and ch.EarningTimingIntervalId != 3
    and ch.EarningTimingTypeId != 3
    and cle.EarningCompletedTimestamp is null

CREATE INDEX IDX1 ON #tmp1(InvoiceId)
CREATE INDEX IDX2 ON #tmp1(NextEarningTimestamp)

SELECT  c.AccountId, a.NextEarningTimestamp, i.CustomerId
INTO    #tmp3
FROM    #tmp1 a INNER JOIN
        Invoice i on a.InvoiceId = i.Id INNER JOIN 
        Customer c on i.CustomerId = c.Id
WHERE  
        c.StatusId <> 3

SELECT  a.AccountId
FROM    #tmp3 a INNER JOIN 
        AccountPreference ap on a.AccountId = ap.Id inner join 
        #ModifiedEndTimestamp MED on ap.TimezoneId = MED.Id 
		INNER JOIN Account aa ON aa.Id = a.AccountId
WHERE  (aa.IncludeInAutomatedProcesses = 1 OR aa.ProcessEarningRegardless = 1) 
	AND a.NextEarningTimestamp < MED.UtcPeriodEndDateTime
GROUP BY 
        A.AccountId

DROP TABLE #ModifiedEndTimestamp
DROP TABLE #tmp1
DROP TABLE #tmp3

set nocount off

GO

