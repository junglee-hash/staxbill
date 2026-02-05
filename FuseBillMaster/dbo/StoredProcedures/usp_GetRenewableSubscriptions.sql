CREATE   procedure [dbo].[usp_GetRenewableSubscriptions]
--DECLARE
@RunDateTime Datetime = null--'2019-03-09 5:05 AM'
AS


set fmtonly off
set nocount on
BEGIN TRY
	if @RunDateTime is null 
		   set @RunDateTime = GETUTCDATE()

	SELECT 
       Id
       ,StandardName
	   ,utcDate.UTCDateTime as UtcPeriodEndDateTime
INTO #ModifiedEndTimestamp
FROM Lookup.Timezone

--NOTE: tried using the new shift function but getting different results and breaking integration tests
--OUTER APPLY Timezone.tvf_GetUTCTimeWithTimezoneShift(Id, @RunDateTime, DEFAULT, DEFAULT, 'day', 1) as utcDate
OUTER APPLY Timezone.tvf_GetTimezoneTime(Id, @RunDateTime) t
OUTER APPLY Timezone.tvf_GetUTCTime(Id, DATEADD(DAY, 1, t.TimezoneDate), DEFAULT, DEFAULT) utcDate


--Get the expiring subscriptions
SELECT
	s.Id as SubscriptionId
	,c.Id as CustomerId
	,c.AccountId
	,s.IntervalId
	,s.BillingPeriodDefinitionId
INTO #ExpiringSubscriptions
FROM Subscription s
INNER JOIN Account a ON a.Id = s.AccountId
INNER JOIN Customer c on c.Id = s.CustomerId
WHERE
	s.StatusId = 2
	AND s.RemainingInterval = 0
	AND a.IncludeInAutomatedProcesses = 1

--Get the email enabled value for all of the customers with expiring subscriptions
;WITH Customers AS
(
	SELECT
		DISTINCT CustomerId, AccountId
	FROM #ExpiringSubscriptions
)
SELECT
	c.CustomerId
	,COALESCE(cep.[Enabled], aet.[Enabled]) AS EmailEnabled
INTO #EnabledEmails
FROM Customers c
INNER JOIN Account a ON a.Id = c.AccountId
INNER JOIN CustomerEmailPreference cep ON cep.CustomerId = c.CustomerId
INNER JOIN AccountEmailTemplate aet ON c.AccountId = aet.AccountId
WHERE COALESCE(cep.[Enabled], aet.[Enabled]) = 1
AND cep.EmailType = 18
AND aet.TypeId = 18
AND a.IncludeInAutomatedProcesses = 1

--Figure out which subscriptions need expiry email
SELECT 
	s.SubscriptionId as Id, s.AccountId, MIN(aes.DaysFromTerm) as DaysFromTerm, MED.UtcPeriodEndDateTime
FROM #ExpiringSubscriptions s
INNER JOIN #EnabledEmails ee ON ee.CustomerId = s.CustomerId
inner join Lookup.Interval on Lookup.Interval.Id = s.IntervalId
	inner join BillingPeriodDefinition bpd ON bpd.Id = s.BillingPeriodDefinitionId
	inner join BillingPeriod bp on bpd.Id = bp.BillingPeriodDefinitionId AND bp.PeriodStatusId = 1
	inner join AccountPreference ap on s.AccountId = ap.Id
		   inner join AccountEmailSchedule aes on aes.AccountId = ap.Id AND aes.[Type] = 'PendingExpiryRenewalNotice' + Lookup.Interval.Name
		   inner join #ModifiedEndTimestamp MED on ap.TimezoneId = MED.Id
	OUTER APPLY Timezone.tvf_GetTimezoneTime(ap.TimezoneId, bp.RechargeDate) RechargeDate
	OUTER APPLY Timezone.tvf_GetUTCTime(ap.TimezoneId, DATEADD(DAY, -aes.DaysFromTerm, RechargeDate.TimezoneDate), DEFAULT, DEFAULT) utcRechargeDate
	WHERE
		   utcRechargeDate.[UTCDateTime] < MED.UtcPeriodEndDateTime
		   and s.CustomerId NOT IN 
			(	
				SELECT 
					CustomerId 
				FROM 
					CustomerEmailControl 
				WHERE 
					CustomerId = s.CustomerId
                    AND EmailKey LIKE 'PendingExpiryRenewalNotice_'+ CAST(s.SubscriptionId as varchar(20)) + '_%'
                    AND (EmailKey = 'PendingExpiryRenewalNotice_' + CAST(s.SubscriptionId as varchar(20)) + '_' + CAST(aes.DaysFromTerm as varchar(20))
                    OR aes.DaysFromTerm > CONVERT(INT,REVERSE(SUBSTRING(REVERSE(EmailKey),0,CHARINDEX('_',REVERSE(EmailKey))))))
			)
	GROUP BY s.SubscriptionId, s.AccountId, MED.UtcPeriodEndDateTime
       
	SET NOCOUNT OFF
	SELECT 0, @RunDateTime
	DROP TABLE #ModifiedEndTimestamp
	DROP TABLE #ExpiringSubscriptions
	DROP TABLE #EnabledEmails
END TRY

BEGIN CATCH
Select 1, @RunDateTime
END CATCH
SET NOCOUNT OFF

GO

