CREATE     PROCEDURE [dbo].[usp_GetCustomerOverviewWithFinancials]
	@AccountId BIGINT
	, @CustomerId BIGINT

AS
BEGIN

SET TRANSACTION ISOLATION LEVEL SNAPSHOT
SET NOCOUNT ON;

DECLARE @UnallocatedCredit MONEY
	, @UnallocatedOpeningBalance MONEY
	, @UnallocatedPayment MONEY
	, @OutstandingBalance MONEY
	, @PendingCharges MONEY
	, @EarnedCredit MONEY
	, @EarnedDebit MONEY
	, @DiscountDebit MONEY
	, @DiscountCredit MONEY
	, @UnknownPaymentActivityId BIGINT


SELECT Id, Amount, TransactionTypeId INTO #CustomerTransactions
FROM [Transaction]
WHERE CustomerId = @CustomerId
	AND TransactionTypeId IN (3, 6, 9, 14, 15, 16, 17, 23, 24)


SET @UnallocatedCredit = (
	SELECT ISNULL(SUM(cr.UnallocatedAmount), 0) 
	FROM Credit cr 
	INNER JOIN #CustomerTransactions t ON cr.Id = t.Id
	WHERE TransactionTypeId = 17
)

SET @UnallocatedOpeningBalance = (
	SELECT ISNULL(SUM(ob.UnallocatedAmount), 0) 
	FROM OpeningBalance ob
	INNER JOIN #CustomerTransactions t ON ob.Id = t.Id
	WHERE TransactionTypeId = 16
)

SET @UnallocatedPayment = (
	SELECT ISNULL(SUM(p.UnallocatedAmount), 0) 
	FROM Payment p
	INNER JOIN #CustomerTransactions t ON p.Id = t.Id
	WHERE TransactionTypeId = 3
)

SET @EarnedCredit = (
	SELECT ISNULL(SUM(Amount), 0)
	FROM #CustomerTransactions
	WHERE TransactionTypeId IN (6)
)

SET @EarnedDebit = (
	SELECT ISNULL(SUM(Amount), 0)
	FROM #CustomerTransactions
	WHERE TransactionTypeId IN (9, 24)
)

SET @DiscountCredit = (
	SELECT ISNULL(SUM(Amount), 0)
	FROM #CustomerTransactions
	WHERE TransactionTypeId IN (15)
)

SET @DiscountDebit = (
	SELECT ISNULL(SUM(Amount), 0)
	FROM #CustomerTransactions
	WHERE TransactionTypeId IN (14, 23)
)

SET @UnknownPaymentActivityId = (
	SELECT MAX(Id)
	FROM PaymentActivityJournal
	WHERE PaymentActivityStatusId = 3
		AND CustomerId = @CustomerId
)

SET @OutstandingBalance = (
	SELECT ISNULL(SUM(ps.OutstandingBalance), 0) 
	FROM PaymentSchedule ps 
	INNER JOIN Invoice i ON i.Id = ps.InvoiceId
		AND i.CustomerId = @CustomerId
)

SET @PendingCharges = (
	SELECT ISNULL(SUM(di.Total), 0) 
	FROM DraftInvoice di
	WHERE di.CustomerId = @CustomerId
		AND di.DraftInvoiceStatusId IN (1,2)
)
 
SELECT 
	c.Id
	,c.AccountId
	,c.EffectiveTimestamp
	,c.Reference
	,@PendingCharges AS PendingCharges
	,@OutstandingBalance - @UnallocatedCredit - @UnallocatedOpeningBalance - @UnallocatedPayment AS ArBalance
	,@EarnedCredit - @EarnedDebit + ISNULL(csd.PreviousLifetimeValue, 0) - cbs.AcquisitionCost - (@DiscountDebit - @DiscountCredit) AS LifeTimeValue
	,@UnallocatedPayment AS AvailableFunds
	,@UnallocatedCredit AS AvailableCredit
	,@UnallocatedOpeningBalance AS AvailableOpeningBalance
	,c.FirstName
	,c.MiddleName
	,c.LastName
	,c.CompanyName
	,c.Suffix
	,c.TitleId as [Title]
	,c.StatusId AS CustomerStatus
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
	,c.AccountStatusId AS CustomerAccountStatus
	,CASE WHEN abp.AutoSuspendEnabled = 1 AND c.AccountStatusId = 2 AND c.StatusId = 2 
			THEN (ISNULL(cbs.CustomerGracePeriod, ISNULL(abp.AccountGracePeriod, 0)) + ISNULL(cbs.GracePeriodExtension, 0) - (DATEDIFF(hh,c.LastAccountStatusJournalTimestamp, GETUTCDATE()) / 24)) 
			ELSE NULL END AS DaysUntilSuspension
	,CASE WHEN abp.AutoSuspendEnabled = 1 AND c.AccountStatusId = 2 AND c.StatusId = 2 AND ISNULL(cbs.CustomerGracePeriod, ISNULL(abp.AccountGracePeriod, 0)) + ISNULL(cbs.GracePeriodExtension, 0) < 999
			THEN  DATEADD(day, (ISNULL(cbs.CustomerGracePeriod, ISNULL(abp.AccountGracePeriod, 0)) + ISNULL(cbs.GracePeriodExtension, 0)- (DATEDIFF(hh,c.LastAccountStatusJournalTimestamp, GETUTCDATE()) / 24)), GETUTCDATE())
			ELSE NULL END AS SuspensionDate
	,CASE WHEN abp.AutoSuspendEnabled = 1 AND c.StatusId = 5 AND c.AccountStatusId = 2 
			THEN (isnull(cbs.CustomerAutoCancel, isnull(abp.AccountAutoCancel, 0)) - (DATEDIFF(hh,c.LastStatusJournalTimestamp, GETUTCDATE()) / 24)) 
			ELSE NULL END AS DaysUntilCancellation
	,CASE WHEN abp.AutoSuspendEnabled = 1 AND c.StatusId = 5 AND c.AccountStatusId = 2  AND isnull(cbs.CustomerAutoCancel, isnull(abp.AccountAutoCancel, 0)) < 999
			THEN DATEADD(day, (isnull(cbs.CustomerAutoCancel, isnull(abp.AccountAutoCancel, 0)) - (DATEDIFF(hh,c.LastStatusJournalTimestamp, GETUTCDATE()) / 24)), c.LastStatusJournalTimestamp) 
			ELSE NULL END AS CancellationDate
	,c.LastAccountStatusJournalTimestamp AS AccountingStatusTimestamp
	,c.LastStatusJournalTimestamp AS ServiceStatusTimestamp
	,CONVERT(money, CASE WHEN afc.MrrDisplayTypeId = 1 
			THEN c.MonthlyRecurringRevenue 
			ELSE c.CurrentMrr END) AS MonthlyRecurringRevenue
	,c.NextBillingDate
	,CONVERT(money, CASE WHEN afc.MrrDisplayTypeId = 1 THEN c.NetMRR ELSE c.CurrentNetMrr END) AS NetMRR
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
LEFT OUTER JOIN CustomerStartingData csd ON c.Id = csd.Id 
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
	,csd.PreviousLifetimeValue
	,cu.IsoName
	,c.AccountStatusId
	,c.LastAccountStatusJournalTimestamp
	,c.StatusId
	,c.LastStatusJournalTimestamp
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
	,cbs.CustomerAutoCancel
	,abp.AccountAutoCancel
	,afc.CustomerHierarchy
	,c.AvalaraId
	,c.AnrokCustomerId

	DROP TABLE #CustomerTransactions

END

GO

