
CREATE VIEW [dbo].[vw_IntegrationSyncCustomerData]
AS
SELECT   DISTINCT     TOP (100) PERCENT sfbr.IntegrationSynchBatchId as BatchId
, cbs.InvoiceDay
, ISNULL(cbs.CustomerGracePeriod, 0) + ISNULL(cbs.GracePeriodExtension, 0) AS GracePeriod
, cur.IsoName AS Currency
, c.SalesforceId
, c.NetsuiteId
, c.Id
, c.Reference
, Lookup.Title.Name AS Title
, c.FirstName
, c.MiddleName
, c.LastName
, c.Suffix
, c.EffectiveTimestamp AS CreatedTimestamp
, c.AccountId
, c.PrimaryEmail
, c.PrimaryPhone
, c.SecondaryEmail
, c.SecondaryPhone
, CASE WHEN COALESCE(c.CompanyName,'') = ''  
       THEN CASE WHEN c.FirstName IS NULL AND c.LastName IS NULL
	        THEN 'Undefined Company Name'
	        ELSE CONCAT(COALESCE(c.FirstName,''), ' ', COALESCE(c.LastName,''))
			END 
	   ELSE c.CompanyName
	   END
	   AS AccountName
, CASE WHEN COALESCE(c.CompanyName,'') = ''  
       THEN CASE WHEN c.FirstName IS NULL AND c.LastName IS NULL
	        THEN 'Undefined Company Name'
	        ELSE CONCAT(COALESCE(c.FirstName,''), ' ', COALESCE(c.LastName,''))
			END 
	   ELSE c.CompanyName
	   END
	   AS CompanyName
, Lookup.CustomerAccountStatus.Name AS AccountStatus
, Lookup.CustomerAccountStatus.Name AS AccountingStatus
, Lookup.CustomerStatus.Name AS Status
, cr.Reference1
, cr.Reference2
, cr.Reference3
, ca.AdContent
, ca.Campaign
, ca.Keyword
, ca.LandingPage
, ca.Medium
, ca.Source
, Lookup.Term.Name AS Terms
, CASE WHEN afc.MrrDisplayTypeId = 1 THEN c.MonthlyRecurringRevenue ELSE c.CurrentMrr END AS MonthlyRecurringRevenue
, CASE WHEN afc.MrrDisplayTypeId = 1 THEN c.NetMRR ELSE c.CurrentNetMrr END AS NetMrr
, CASE WHEN (cbs.AutoCollect = 1) THEN 'On' WHEN (cbs.AutoCollect = 0) THEN 'Off' WHEN (cbs.AutoCollect IS NULL) THEN 'Account Default' END AS AutoCollect

FROM            dbo.Customer c INNER JOIN
                         dbo.IntegrationSynchBatchRecord AS sfbr ON sfbr.EntityId = c.Id INNER JOIN
						 dbo.IntegrationSynchBatch AS sfb ON sfb.Id = sfbr.IntegrationSynchBatchId INNER JOIN
                         dbo.CustomerAccountStatusJournal AS cj ON c.Id = cj.CustomerId AND cj.IsActive = 1 INNER JOIN
                         dbo.CustomerStatusJournal AS csj ON c.Id = csj.CustomerId AND csj.IsActive = 1 INNER JOIN
                         dbo.CustomerBillingSetting AS cbs ON c.Id = cbs.Id INNER JOIN
                         dbo.AccountBillingPreference AS bp ON c.AccountId = bp.Id INNER JOIN
						 dbo.AccountFeatureConfiguration AS afc on c.AccountId = afc.Id LEFT OUTER JOIN
                         Lookup.CustomerStatus ON csj.StatusId = Lookup.CustomerStatus.Id LEFT OUTER JOIN
                         Lookup.CustomerAccountStatus ON cj.StatusId = Lookup.CustomerAccountStatus.Id LEFT OUTER JOIN
                         Lookup.Term ON cbs.TermId = Lookup.Term.Id LEFT OUTER JOIN
                         dbo.CustomerAcquisition AS ca ON ca.Id = c.Id LEFT OUTER JOIN
                         dbo.CustomerReference AS cr ON cr.Id = c.Id LEFT OUTER JOIN
                         Lookup.Currency AS cur ON cur.Id = c.CurrencyId LEFT OUTER JOIN
                         Lookup.Title ON c.TitleId = Lookup.Title.Id
						 WHERE        (sfbr.EntityTypeId = 3) AND (sfb.StatusId NOT IN (4, 5)) ORDER BY c.Id

GO

