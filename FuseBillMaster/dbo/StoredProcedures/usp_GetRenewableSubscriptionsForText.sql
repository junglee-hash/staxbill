CREATE   procedure [dbo].[usp_GetRenewableSubscriptionsForText]
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


	SELECT
		   s.Id, c.AccountId, MIN(aes.DaysFromTerm) as DaysFromTerm, MED.UtcPeriodEndDateTime
	FROM Subscription s
	inner join Account a on a.Id = s.AccountId
	inner join Customer c on c.Id = s.CustomerId
	inner join Lookup.Interval on Lookup.Interval.Id = s.IntervalId
	inner join BillingPeriodDefinition bpd ON bpd.Id = s.BillingPeriodDefinitionId
	inner join BillingPeriod bp on bpd.Id = bp.BillingPeriodDefinitionId AND bp.PeriodStatusId = 1
	inner join AccountPreference ap on c.AccountId = ap.Id
		   inner join AccountTxtSchedule aes on aes.AccountId = ap.Id AND aes.[Type] = 'PendingExpiryRenewalNotice' + Lookup.Interval.Name
		   inner join #ModifiedEndTimestamp MED on ap.TimezoneId = MED.Id
	inner join CustomerSmsNumber sms ON c.Id = sms.CustomerId AND sms.SmsStatusId = 2
		-- there may not be customer text preference because it only gets set on change
	left join CustomerTxtPreference cep ON c.Id = cep.CustomerId AND cep.TxtTypeId = 6
	inner join AccountTxtTemplate aet ON c.AccountId = aet.AccountId AND aet.TxtTypeId = 6
	OUTER APPLY Timezone.tvf_GetTimezoneTime(ap.TimezoneId, bp.RechargeDate) RechargeDate
	OUTER APPLY Timezone.tvf_GetUTCTime(ap.TimezoneId, DATEADD(DAY, -aes.DaysFromTerm, RechargeDate.TimezoneDate), DEFAULT, DEFAULT) utcRechargeDate
	WHERE
		s.StatusId = 2 AND s.RemainingInterval = 0 AND COALESCE(cep.[Enabled], aet.[Enabled]) = 1 AND
		   utcRechargeDate.[UTCDateTime] < MED.UtcPeriodEndDateTime
		   and a.IncludeInAutomatedProcesses = 1
		   and c.Id NOT IN 
			(	
				SELECT 
					CustomerId 
				FROM 
					CustomerTxtControl 
				WHERE 
					CustomerId = c.Id 
					AND TxtKey LIKE 'PendingExpiryRenewalNotice_'+ CAST(s.Id as varchar(20)) + '_%'
                    AND (TxtKey = 'PendingExpiryRenewalNotice_' + CAST(s.Id as varchar(20)) + '_' + CAST(aes.DaysFromTerm as varchar(20))
                    OR aes.DaysFromTerm > CONVERT(INT,REVERSE(SUBSTRING(REVERSE(TxtKey),0,CHARINDEX('_',REVERSE(TxtKey))))))
			)
	GROUP BY s.Id, c.AccountId, MED.UtcPeriodEndDateTime
       
	SET NOCOUNT OFF
	SELECT 0, @RunDateTime
	DROP TABLE #ModifiedEndTimestamp
END TRY

BEGIN CATCH
Select 1, @RunDateTime
END CATCH
SET NOCOUNT OFF

GO

