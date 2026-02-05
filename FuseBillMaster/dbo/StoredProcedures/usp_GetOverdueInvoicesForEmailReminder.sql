
CREATE     PROCEDURE [dbo].[usp_GetOverdueInvoicesForEmailReminder]
@AccountId bigint = null,
@RunDateTime Datetime = NULL
AS

set nocount on

if @RunDateTime is null 
       set @RunDateTime = GETUTCDATE()

DECLARE @deprioritizedAccount BIGINT = 24626 -- Protection Plan Centre

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

CREATE TABLE #InvoiceData(
InvoiceId BIGINT,
PaymentScheduleId BIGINT,
AccountId BIGINT,
CustomerId BIGINT,
DueDate DATETIME,
Priority TINYINT
)

if (@AccountId is null)
	begin 
		Insert into #InvoiceData
		SELECT
		i.Id as InvoiceId,
		ps.Id as PaymentScheduleId,
		i.AccountId,
		i.CustomerId,
		ps.DueDate,
		CASE WHEN i.AccountId = @deprioritizedAccount THEN 1 ELSE 2 END AS [Priority]
		FROM invoice i
		INNER JOIN Account a ON a.Id = i.AccountId
		inner join PaymentSchedule ps
		on ps.InvoiceId = i.Id
		WHERE ps.StatusId = 3
			AND ps.LastJournalTimestamp > DATEADD(YEAR,-1,@RunDateTime)
			AND a.IncludeInAutomatedProcesses = 1
	end
else 
	begin 
		Insert into #InvoiceData
		SELECT
		i.Id as InvoiceId,
		ps.Id as PaymentScheduleId,
		i.AccountId,
		i.CustomerId,
		ps.DueDate,
		CASE WHEN i.AccountId = @deprioritizedAccount THEN 1 ELSE 2 END AS [Priority]
		FROM invoice i
		INNER JOIN Account a ON a.Id = i.AccountId
		inner join PaymentSchedule ps
		on ps.InvoiceId = i.Id
		WHERE ps.StatusId = 3
			AND ps.LastJournalTimestamp > DATEADD(YEAR,-1,@RunDateTime)
			and i.AccountId = @AccountId
			AND a.IncludeInAutomatedProcesses = 1
	end
	

SELECT top 5000
       i.InvoiceId as ID, i.PaymentScheduleId, c.AccountId, MAX(aes.DaysFromTerm) as DaysFromTerm, MED.UtcPeriodEndDateTime
FROM #InvoiceData i
INNER JOIN AccountEmailTemplate aet ON aet.AccountId = i.AccountId AND aet.TypeId = 3 -- Invoice Overdue
INNER JOIN CustomerEmailPreference cep ON cep.CustomerId = i.CustomerId AND cep.EmailType = 3 -- Invoice Overdue - uses EmailTemplateType not EmailType

inner join customer c on c.Id = i.CustomerId and c.StatusId in (2,5) -- active and suspended
inner join AccountPreference ap on i.AccountId = ap.Id
inner join AccountEmailSchedule aes on aes.AccountId = ap.Id AND aes.[Type] = 'Overdue'
inner join #ModifiedEndTimestamp MED on ap.TimezoneId = MED.Id
LEFT JOIN CustomerEmailControl cec ON cec.CustomerId = i.CustomerId AND cec.EmailTypeId = 6 
	AND cec.InvoiceId = i.InvoiceId AND i.PaymentScheduleId = cec.PaymentScheduleId 
	AND cec.Days = aes.DaysFromTerm
WHERE 

	COALESCE(cep.[Enabled],aet.[Enabled]) = 1 
	AND 
		DATEADD(Day, aes.DaysFromTerm, i.DueDate) < MED.UtcPeriodEndDateTime 
		AND
		aes.DaysFromTerm > ISNULL(cec.Days, -1)
GROUP BY i.InvoiceId, i.PaymentScheduleId, c.AccountId, MED.UtcPeriodEndDateTime, i.Priority
ORDER BY I.Priority DESC

SET NOCOUNT OFF
SELECT 0, @RunDateTime

DROP TABLE #ModifiedEndTimestamp
DROP TABLE #InvoiceData

GO

