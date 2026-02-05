--Stopgap
CREATE     PROC [dbo].[usp_GetRenewableInvoices]
@RunDateTime Datetime = NULL
,@AccountId bigint
AS
set transaction isolation level snapshot
set nocount on

BEGIN TRY

if @RunDateTime is null 
    set @RunDateTime = GETUTCDATE()

DECLARE @CutoffDate DATETIME = DATEADD(YEAR, -1, @RunDateTime)

declare @TimezoneId int = (select TimezoneId from AccountPreference where id = @AccountId)
declare @TimezoneDate datetime = (select TimezoneDate from Timezone.tvf_GetTimezoneTime(@TimezoneId, @RunDateTime))
declare @UtcDateTime datetime = (select [UTCDateTime] from Timezone.tvf_GetUTCTime(@TimezoneId, DATEADD(DAY, 1, @TimezoneDate), DEFAULT, DEFAULT))

SELECT
       ps.InvoiceId as Id
FROM  PaymentSchedule ps 
join Invoice i on ps.InvoiceId = i.Id
		WHERE 
		i.AccountId = @AccountId
		and ps.DueDate < @UtcDateTime
		AND ps.LastJournalTimestamp >= @CutoffDate
		AND  ps.StatusId in (1,2)
GROUP BY ps.InvoiceId, ps.id, ps.DueDate

SET NOCOUNT OFF
SELECT 0, @RunDateTime

END TRY

BEGIN CATCH
Select 1, @RunDateTime
END CATCH
SET NOCOUNT OFF

GO

