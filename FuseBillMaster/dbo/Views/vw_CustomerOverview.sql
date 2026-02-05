CREATE   VIEW [dbo].[vw_CustomerOverview]
AS

WITH Currencies AS 
	(
	SELECT Id, IsoName
	FROM Lookup.Currency)

,CustomerLedgerBalance AS 
	(
	SELECT 
	CustomerId
	,SUM(ArCredit) AS ArBalanceCredit
	,SUM(ArDebit) AS ArBalanceDebit
	,SUM(EarnedCredit) AS EarnedCredit
	,SUM(EarnedDebit) AS EarnedDebit
	,SUM(DiscountCredit) AS DiscountCredit
	,SUM(DiscountDebit) AS DiscountDebit
	FROM vw_CustomerLedgerJournal
	GROUP BY CustomerId)
	 
,Credit_UnallocatedAmount AS
	(	
	SELECT t.CustomerId
	,SUM(cr.UnallocatedAmount) AS UnallocatedAmount
	FROM Credit cr
	INNER JOIN [Transaction] t ON cr.Id = t.Id
	WHERE t.TransactionTypeId = 17
	GROUP BY t.CustomerId)

,OpeningBalance_UnallocatedAmount AS
	(	
	SELECT t.CustomerId
	,SUM(ob.UnallocatedAmount) AS UnallocatedAmount
	FROM OpeningBalance ob
	INNER JOIN [Transaction] t ON ob.Id = t.Id
	WHERE t.TransactionTypeId = 16
	GROUP BY t.CustomerId)

,Payment_UnallocatedAmount AS
	(	
	SELECT t.CustomerId
	,SUM(p.UnallocatedAmount) AS UnallocatedAmount
	FROM Payment p
	INNER JOIN [Transaction] t ON p.Id = t.Id
	WHERE t.TransactionTypeId = 3
	GROUP BY t.CustomerId)

,Payment_Unknown AS
	(
	SELECT CustomerId,
	MAX(Id) as UnknownPaymentActivityId
	FROM PaymentActivityJournal
	WHERE [PaymentActivityStatusId] = 3
	GROUP BY CustomerId
	HAVING COUNT(Id) > 0)

SELECT 
	c.Id
	,c.AccountId
	,c.EffectiveTimestamp
	,c.Reference
	,ISNULL(SUM(di.Total), 0) AS PendingCharges
	,ISNULL(lb.ArBalanceDebit, 0) - ISNULL(lb.ArBalanceCredit, 0) AS ArBalance
	,ISNULL(lb.EarnedCredit, 0) - ISNULL(lb.EarnedDebit, 0) + ISNULL(csd.PreviousLifetimeValue, 0) - cbs.AcquisitionCost - (ISNULL(lb.DiscountDebit, 0) - ISNULL(lb.DiscountCredit, 0)) AS LifeTimeValue
	,ISNULL(pua.UnallocatedAmount,0) AS AvailableFunds
	,ISNULL(cua.UnallocatedAmount,0) AS AvailableCredit
	,ISNULL(obua.UnallocatedAmount, 0) AS AvailableOpeningBalance
	,c.FirstName
	,c.MiddleName
	,c.LastName
	,c.CompanyName
	,c.Suffix
	,c.TitleId
	,csj.StatusId AS CustomerStatusId
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
	,cj.StatusId AS CustomerAccountStatusId
	,CASE WHEN abp.AutoSuspendEnabled = 1 AND cj.StatusId = 2 AND csj.StatusId = 2 
			THEN (ISNULL(cbs.CustomerGracePeriod, ISNULL(abp.AccountGracePeriod, 0)) + ISNULL(cbs.GracePeriodExtension, 0) - (DATEDIFF(hh,cj.EffectiveTimestamp, GETUTCDATE()) / 24)) 
			ELSE NULL END AS DaysUntilSuspension
	,CASE WHEN abp.AutoSuspendEnabled = 1 AND cj.StatusId = 2 AND csj.StatusId = 2 AND ISNULL(cbs.CustomerGracePeriod, ISNULL(abp.AccountGracePeriod, 0)) + ISNULL(cbs.GracePeriodExtension, 0) < 999
			THEN  DATEADD(day, (ISNULL(cbs.CustomerGracePeriod, ISNULL(abp.AccountGracePeriod, 0)) + ISNULL(cbs.GracePeriodExtension, 0)- (DATEDIFF(hh,cj.EffectiveTimestamp, GETUTCDATE()) / 24)), cj.EffectiveTimestamp)
			ELSE NULL END AS SuspensionDate
	,CASE WHEN abp.AutoSuspendEnabled = 1 AND c.StatusId = 5 AND c.AccountStatusId = 2 
			THEN (isnull(cbs.CustomerAutoCancel, isnull(abp.AccountAutoCancel, 0)) - (DATEDIFF(hh,csj.EffectiveTimestamp, GETUTCDATE()) / 24)) 
			ELSE NULL END AS DaysUntilCancellation
	,CASE WHEN abp.AutoSuspendEnabled = 1 AND c.StatusId = 5 AND c.AccountStatusId = 2 AND isnull(cbs.CustomerAutoCancel, isnull(abp.AccountAutoCancel, 0)) < 999
			THEN DATEADD(day, (isnull(cbs.CustomerAutoCancel, isnull(abp.AccountAutoCancel, 0)) - (DATEDIFF(hh,csj.EffectiveTimestamp, GETUTCDATE()) / 24)), csj.EffectiveTimestamp) 
			ELSE NULL END AS CancellationDate
	,cj.EffectiveTimestamp AS AccountingStatusTimestamp
	,csj.CreatedTimestamp AS ServiceStatusTimestamp
	,CASE WHEN afc.MrrDisplayTypeId = 1 
			THEN c.MonthlyRecurringRevenue 
			ELSE c.CurrentMrr END AS MonthlyRecurringRevenue
	,c.NextBillingDate
	,CASE WHEN afc.MrrDisplayTypeId = 1 THEN c.NetMRR ELSE c.CurrentNetMrr END AS NetMRR
	,c.SalesforceSynchStatusId
	,parent.Id AS ParentId
	,parent.FirstName AS ParentFirstName
	,parent.LastName AS ParentLastName
	,parent.CompanyName AS ParentCompanyName
	,unknown.UnknownPaymentActivityId
	,afc.CustomerHierarchy as CustomerHierarchyOn
	,c.AvalaraId
	,c.AnrokCustomerId
FROM Customer c 
INNER JOIN AccountFeatureConfiguration afc ON afc.Id = c.AccountId 
INNER JOIN CustomerAddressPreference cap ON c.Id = cap.Id 
LEFT OUTER JOIN [Address] a ON cap.Id = a.CustomerAddressPreferenceId AND a.AddressTypeId = 1 
INNER JOIN CustomerBillingSetting cbs ON c.Id = cbs.Id 
INNER JOIN AccountBillingPreference abp ON c.AccountId = abp.Id 
LEFT OUTER JOIN DraftInvoice di ON di.CustomerId = c.Id AND di.DraftInvoiceStatusId IN(1,2) 
LEFT OUTER JOIN CustomerLedgerBalance lb ON c.Id = lb.CustomerId 
INNER JOIN Currencies cu ON c.CurrencyId = cu.Id 
INNER JOIN CustomerAccountStatusJournal cj ON c.Id = cj.CustomerId AND cj.IsActive = 1 
INNER JOIN CustomerStatusJournal csj ON c.Id = csj.CustomerId AND csj.IsActive = 1 
LEFT OUTER JOIN CustomerStartingData csd ON c.Id = csd.Id 
LEFT OUTER JOIN Credit_UnallocatedAmount cua ON c.Id = cua.CustomerId
LEFT OUTER JOIN OpeningBalance_UnallocatedAmount obua ON c.Id = obua.CustomerId
LEFT OUTER JOIN Payment_UnallocatedAmount pua ON c.Id = pua.CustomerId
LEFT OUTER JOIN Customer parent ON afc.CustomerHierarchy = 1 AND parent.Id = c.ParentId
LEFT OUTER JOIN Payment_Unknown unknown ON c.Id = unknown.CustomerId
LEFT OUTER JOIN CustomerIntegration ciContact ON c.Id = ciContact.CustomerId AND ciContact.CustomerIntegrationTypeId = 1 --Hubspot Contact
LEFT OUTER JOIN CustomerIntegration ciCompany ON c.Id = ciCompany.CustomerId AND ciCompany.CustomerIntegrationTypeId = 2 --Hubspot Company
LEFT OUTER JOIN CustomerIntegration ciGeotab ON c.Id = ciGeotab.CustomerId AND ciGeotab.CustomerIntegrationTypeId = 3 --Geotab
LEFT OUTER JOIN CustomerIntegration ciDigitalRiver ON c.Id = ciDigitalRiver.CustomerId AND ciDigitalRiver.CustomerIntegrationTypeId = 4 --Digital River
WHERE c.IsDeleted = 0
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
	,lb.ArBalanceDebit
	,lb.ArBalanceCredit
	,lb.EarnedCredit
	,lb.EarnedDebit
	,lb.DiscountCredit
	,lb.DiscountDebit
	,cua.UnallocatedAmount
	,obua.UnallocatedAmount
	,pua.UnallocatedAmount
	,csd.PreviousLifetimeValue
	,cu.IsoName
	,cj.StatusId
	,cj.EffectiveTimestamp
	,csj.StatusId
	,csj.CreatedTimestamp
	,cbs.CustomerGracePeriod
	,cbs.GracePeriodExtension
	,cbs.AcquisitionCost
	,abp.AccountGracePeriod
	,parent.Id
	,parent.FirstName
	,parent.LastName
	,parent.CompanyName
	,c.StatusId
	,c.AccountStatusId
	,csj.EffectiveTimestamp
	,cbs.CustomerAutoCancel
	,abp.AccountAutoCancel
	,abp.AutoSuspendEnabled
	,unknown.UnknownPaymentActivityId
	,afc.CustomerHierarchy
	,c.AvalaraId
	,c.AnrokCustomerId

GO

