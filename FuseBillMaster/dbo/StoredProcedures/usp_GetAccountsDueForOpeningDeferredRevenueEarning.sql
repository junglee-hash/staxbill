CREATE   Procedure [dbo].[usp_GetAccountsDueForOpeningDeferredRevenueEarning]
	@RunDateTime datetime = null
AS

if @RunDateTime is null
	set @RunDateTime = GETUTCDATE()

set fmtonly off
set nocount on
		
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

select c.AccountId
from OpeningDeferredRevenue cle
inner join [Transaction] t ON t.Id = cle.Id
inner join Customer c ON c.Id = t.CustomerId
inner join AccountPreference ap on c.AccountId = ap.Id
inner join #ModifiedEndTimestamp MED on ap.TimezoneId = MED.Id
INNER JOIN Account a ON a.Id = c.AccountId
WHERE cle.NextEarningTimestamp < MED.UtcPeriodEndDateTime
AND (a.IncludeInAutomatedProcesses = 1 OR a.ProcessEarningRegardless = 1)
and cle.CompletedEarningTimestamp is null
group by c.AccountId

set nocount off

GO

