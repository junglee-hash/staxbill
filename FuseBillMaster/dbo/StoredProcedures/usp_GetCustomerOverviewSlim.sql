CREATE      PROCEDURE [dbo].[usp_GetCustomerOverviewSlim]
	@AccountId BIGINT
	, @CustomerId BIGINT

AS
BEGIN

SET TRANSACTION ISOLATION LEVEL SNAPSHOT
SET NOCOUNT ON;

DECLARE @UnallocatedCredit MONEY
	, @UnallocatedOpeningBalance MONEY
	, @UnallocatedPayment MONEY
	, @UnknownPaymentActivityId BIGINT

SELECT Id, Amount, TransactionTypeId INTO #CustomerTransactions
FROM [Transaction]
WHERE CustomerId = @CustomerId
	AND TransactionTypeId IN (3, 16, 17)


SET @UnallocatedCredit = (
	SELECT ISNULL(SUM(cr.UnallocatedAmount), 0) 
	FROM Credit cr 
	INNER JOIN #CustomerTransactions t ON cr.Id = t.Id
)

SET @UnallocatedOpeningBalance = (
	SELECT ISNULL(SUM(ob.UnallocatedAmount), 0) 
	FROM OpeningBalance ob
	INNER JOIN #CustomerTransactions t ON ob.Id = t.Id
)

SET @UnallocatedPayment = (
	SELECT ISNULL(SUM(p.UnallocatedAmount), 0) 
	FROM Payment p
	INNER JOIN #CustomerTransactions t ON p.Id = t.Id
)

SET @UnknownPaymentActivityId = (
	SELECT MAX(Id)
	FROM PaymentActivityJournal
	WHERE PaymentActivityStatusId = 3
		AND CustomerId = @CustomerId
)

SELECT 
	c.Id
	,c.AccountId
	,c.EffectiveTimestamp
	,c.Reference
	,CONVERT(money, 0) AS PendingCharges
	,CONVERT(money, 0) AS ArBalance
	,CONVERT(money, 0) AS LifeTimeValue
	,@UnallocatedPayment AS AvailableFunds
	,@UnallocatedCredit AS AvailableCredit
	,@UnallocatedOpeningBalance AS AvailableOpeningBalance
	,c.FirstName
	,c.MiddleName
	,c.LastName
	,c.CompanyName
	,c.Suffix
	,c.TitleId as [Title]
	,csj.StatusId AS CustomerStatus
	,cu.IsoName AS Currency 
	,c.PrimaryEmail
	,c.SecondaryEmail
	,c.PrimaryPhone
	,c.SecondaryPhone
	,c.SageIntacctId
	,c.QuickBooksId
	,c.SalesforceId
	,c.NetsuiteId
	,c.IsDeleted
	,Convert(BIGINT, ciContact.IntegrationId) AS HubSpotId
	,Convert(BIGINT, ciCompany.IntegrationId) AS HubSpotCompanyId
	,ciGeotab.IntegrationId AS GeotabId
	,ciDigitalRiver.IntegrationId AS DigitalRiverId
	,cj.StatusId AS CustomerAccountStatus
	,CASE WHEN abp.AutoSuspendEnabled = 1 AND cj.StatusId = 2 AND csj.StatusId = 2 
			THEN (ISNULL(cbs.CustomerGracePeriod, ISNULL(abp.AccountGracePeriod, 0)) + ISNULL(cbs.GracePeriodExtension, 0) - (DATEDIFF(hh,cj.EffectiveTimestamp, GETUTCDATE()) / 24)) 
			ELSE NULL END AS DaysUntilSuspension
	,CASE WHEN abp.AutoSuspendEnabled = 1 AND cj.StatusId = 2 AND csj.StatusId = 2 AND ISNULL(cbs.CustomerGracePeriod, ISNULL(abp.AccountGracePeriod, 0)) + ISNULL(cbs.GracePeriodExtension, 0) < 999
			THEN  DATEADD(day, (ISNULL(cbs.CustomerGracePeriod, ISNULL(abp.AccountGracePeriod, 0)) + ISNULL(cbs.GracePeriodExtension, 0)- (DATEDIFF(hh,cj.EffectiveTimestamp, GETUTCDATE()) / 24)), GETUTCDATE())
			ELSE NULL END AS SuspensionDate
	,CASE WHEN abp.AutoSuspendEnabled = 1 AND c.StatusId = 5 AND c.AccountStatusId = 2 
			THEN (isnull(cbs.CustomerAutoCancel, isnull(abp.AccountAutoCancel, 0)) - (DATEDIFF(hh,csj.EffectiveTimestamp, GETUTCDATE()) / 24)) 
			ELSE NULL END AS DaysUntilCancellation
	,CASE WHEN abp.AutoSuspendEnabled = 1 AND c.StatusId = 5 AND c.AccountStatusId = 2  AND isnull(cbs.CustomerAutoCancel, isnull(abp.AccountAutoCancel, 0)) < 999
			THEN DATEADD(day, (isnull(cbs.CustomerAutoCancel, isnull(abp.AccountAutoCancel, 0)) - (DATEDIFF(hh,csj.EffectiveTimestamp, GETUTCDATE()) / 24)), csj.EffectiveTimestamp) 
			ELSE NULL END AS CancellationDate
	,cj.EffectiveTimestamp AS AccountingStatusTimestamp
	,csj.CreatedTimestamp AS ServiceStatusTimestamp
	,CASE WHEN afc.MrrDisplayTypeId = 1 
			THEN c.MonthlyRecurringRevenue 
			ELSE c.CurrentMrr END AS MonthlyRecurringRevenue
	,c.NextBillingDate
	,CASE WHEN afc.MrrDisplayTypeId = 1 THEN c.NetMRR ELSE c.CurrentNetMrr END AS NetMRR
	,c.SalesforceSynchStatusId as SalesforceSynchStatus
	,parent.Id AS ParentId
	,parent.FirstName AS ParentFirstName
	,parent.LastName AS ParentLastName
	,parent.CompanyName AS ParentCompanyName
	,@UnknownPaymentActivityId as UnknownPaymentActivityId
	,afc.CustomerHierarchy as CustomerHierarchyOn
	,c.AvalaraId
	,c.AnrokCustomerId
FROM Customer c 
INNER JOIN AccountFeatureConfiguration afc ON afc.Id = c.AccountId 
INNER JOIN CustomerAddressPreference cap ON c.Id = cap.Id 
LEFT OUTER JOIN [Address] a ON cap.Id = a.CustomerAddressPreferenceId AND a.AddressTypeId = 1 
INNER JOIN CustomerBillingSetting cbs ON c.Id = cbs.Id 
INNER JOIN AccountBillingPreference abp ON c.AccountId = abp.Id 
INNER JOIN Lookup.Currency cu ON c.CurrencyId = cu.Id 
INNER JOIN CustomerAccountStatusJournal cj ON c.Id = cj.CustomerId AND cj.IsActive = 1 
INNER JOIN CustomerStatusJournal csj ON c.Id = csj.CustomerId AND csj.IsActive = 1 
LEFT OUTER JOIN Customer parent ON afc.CustomerHierarchy = 1 AND parent.Id = c.ParentId
LEFT OUTER JOIN CustomerIntegration ciContact ON c.Id = ciContact.CustomerId AND ciContact.CustomerIntegrationTypeId = 1 --Hubspot Contact
LEFT OUTER JOIN CustomerIntegration ciCompany ON c.Id = ciCompany.CustomerId AND ciCompany.CustomerIntegrationTypeId = 2 --Hubspot Company
LEFT OUTER JOIN CustomerIntegration ciGeotab ON c.Id = ciGeotab.CustomerId AND ciGeotab.CustomerIntegrationTypeId = 3 --Geotab
LEFT OUTER JOIN CustomerIntegration ciDigitalRiver ON c.Id = ciDigitalRiver.CustomerId AND ciDigitalRiver.CustomerIntegrationTypeId = 4 --Digital River
WHERE c.IsDeleted = 0
	AND c.Id = @CustomerId
	AND c.AccountId = @AccountId
GROUP BY 
	c.Id
	,c.AccountId
	,afc.MrrDisplayTypeId
	,c.EffectiveTimestamp
	,c.Reference
	,c.FirstName
	,c.MiddleName
	,c.LastName
	,c.CompanyName
	,c.Suffix
	,c.TitleId
	,c.PrimaryEmail
	,c.SecondaryEmail
	,c.PrimaryPhone
	,c.SecondaryPhone
	,c.NetMRR
	,c.MonthlyRecurringRevenue
	,c.NextBillingDate
	,c.CurrentNetMrr
	,c.CurrentMrr
	,c.SalesforceSynchStatusId
	,c.SageIntacctId
	,c.QuickBooksId
	,c.SalesforceId
	,c.NetsuiteId
	,c.IsDeleted
	,ciContact.IntegrationId
	,ciCompany.IntegrationId
	,ciGeotab.IntegrationId
	,ciDigitalRiver.IntegrationId
	,cu.IsoName
	,cj.StatusId
	,cj.EffectiveTimestamp
	,csj.StatusId
	,csj.CreatedTimestamp
	,cbs.CustomerGracePeriod
	,cbs.GracePeriodExtension
	,cbs.AcquisitionCost
	,abp.AccountGracePeriod
	,abp.AutoSuspendEnabled
	,parent.Id
	,parent.FirstName
	,parent.LastName
	,parent.CompanyName
	,c.StatusId
	,c.AccountStatusId
	,csj.EffectiveTimestamp
	,cbs.CustomerAutoCancel
	,abp.AccountAutoCancel
	,afc.CustomerHierarchy
	,c.AvalaraId
	,c.AnrokCustomerId

	DROP TABLE #CustomerTransactions

END

GO

