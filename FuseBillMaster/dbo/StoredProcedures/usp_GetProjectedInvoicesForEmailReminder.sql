CREATE   procedure [dbo].[usp_GetProjectedInvoicesForEmailReminder]
@RunDateTime Datetime = NULL
AS

set nocount on
BEGIN TRY
if @RunDateTime is null 
       set @RunDateTime = GETUTCDATE()

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
	di.Id as DraftInvoiceId
	,c.Id as CustomerId
	,c.AccountId
	,bpd.IntervalId
	,di.EffectiveTimestamp
	,di.Total
INTO #ProjectedInvoices
FROM DraftInvoice di
inner join Customer c on c.Id = di.CustomerId AND c.StatusId = 2 --Active only
inner join Account a ON a.Id = c.AccountId
inner join BillingPeriod bp ON bp.Id = di.BillingPeriodId
inner join BillingPeriodDefinition bpd ON bpd.Id = bp.BillingPeriodDefinitionId
WHERE
	di.DraftInvoiceStatusId = 5
	AND a.IncludeInAutomatedProcesses = 1

--Get the email enabled value for all of the customers with expiring subscriptions
;WITH Customers AS
(
	SELECT
		DISTINCT CustomerId, AccountId
	FROM #ProjectedInvoices
)
SELECT
	c.CustomerId
	,COALESCE(cep.[Enabled], aet.[Enabled]) AS EmailEnabled
	,aet.Send0DollarInvoices
INTO #EnabledEmails
FROM Customers c
INNER JOIN CustomerEmailPreference cep ON cep.CustomerId = c.CustomerId
INNER JOIN AccountEmailTemplate aet ON c.AccountId = aet.AccountId
WHERE COALESCE(cep.[Enabled], aet.[Enabled]) = 1
AND cep.EmailType = 16
AND aet.TypeId = 16

SELECT
       di.DraftInvoiceId as Id, di.AccountId, aes.DaysFromTerm, MED.UtcPeriodEndDateTime
FROM #ProjectedInvoices di
INNER JOIN #EnabledEmails ee ON ee.CustomerId = di.CustomerId
inner join Lookup.Interval on Lookup.Interval.Id = di.IntervalId
inner join AccountPreference ap on di.AccountId = ap.Id
       inner join AccountEmailSchedule aes on aes.AccountId = di.AccountId AND aes.[Type] = 'UpcomingBillingNotification' + Lookup.Interval.Name
       inner join #ModifiedEndTimestamp MED on ap.TimezoneId = MED.Id
WHERE
	
       DATEADD(Day, -aes.DaysFromTerm, di.EffectiveTimestamp) < MED.UtcPeriodEndDateTime
       and di.CustomerId NOT IN 
		(SELECT CustomerId FROM CustomerEmailControl WHERE CustomerId = di.CustomerId AND EmailKey = 'UpcomingBillingNotification_' + CAST(di.DraftInvoiceId as varchar(20)))
       -- check don't send $0 invoices setting
	   AND di.Total > CASE WHEN ee.Send0DollarInvoices = 1 THEN -1 ELSE 0 END
	   GROUP BY di.DraftInvoiceId, di.AccountId, aes.DaysFromTerm, MED.UtcPeriodEndDateTime

SET NOCOUNT OFF
SELECT 0, @RunDateTime
DROP TABLE #ModifiedEndTimestamp
	DROP TABLE #ProjectedInvoices
	DROP TABLE #EnabledEmails

END TRY

BEGIN CATCH
Select 1, @RunDateTime
END CATCH
SET NOCOUNT OFF

GO

