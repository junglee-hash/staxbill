CREATE VIEW [dbo].[vw_CustomersEligibleForSuspension]
AS


SELECT
	 c.Id
	, c.AccountStatusId
	, c.LastAccountStatusJournalTimestamp as PoorStandingDay
	, cbs.CustomerGracePeriod
	, cbs.GracePeriodExtension
	, abp.AccountGracePeriod
FROM 
Customer c
INNER JOIN CustomerBillingSetting cbs ON cbs.Id = c.Id
INNER JOIN AccountBillingPreference abp ON abp.id = c.AccountId
INNER JOIN Account a ON a.Id = c.AccountId
WHERE 
	abp.AutoSuspendEnabled = 1
	AND c.StatusId = 2
	AND c.AccountStatusId = 2 
	AND coalesce(cbs.CustomerGracePeriod,abp.AccountGracePeriod)+isnull(cbs.GracePeriodExtension,0) <=datediff(day,c.LastAccountStatusJournalTimestamp,getutcdate())
	AND a.IncludeInAutomatedProcesses = 1

GO

