
CREATE VIEW [dbo].[vw_DraftInvoiceSummary]
AS
SELECT	dbo.DraftInvoice.Id, 
		dbo.DraftInvoice.EffectiveTimestamp AS EffectiveDate, 
		dbo.DraftInvoice.Total AS PendingCharges, 
		dbo.DraftInvoice.CreatedTimestamp AS CreatedDate,
		dbo.DraftInvoice.ModifiedTimestamp AS ModifiedTimestamp,
		dbo.DraftInvoice.PoNumber as PoNumber,
		dbo.Customer.Id AS CustomerId, 
		dbo.Customer.AccountId, 
		dbo.Customer.Reference, 
        dbo.Customer.CurrencyId, 
		dbo.Customer.FirstName,
		dbo.Customer.LastName,
		dbo.Customer.MiddleName,
		dbo.Customer.CompanyName,
		dbo.Customer.PrimaryEmail,
		dbo.DraftInvoice.DraftInvoiceStatusId,
		dbo.BillingPeriod.StartDate AS BillingPeriodStartDate,
		dbo.BillingPeriod.EndDate AS BillingPeriodEndDate,
		dbo.Customer.ParentId AS CustomerParentId,
		dbo.Customer.IsParent as CustomerIsParent,
		Lookup.CustomerAccountStatus.Name AS AccountingStatus,
		Lookup.CustomerStatus.Name AS CustomerStatus
FROM    dbo.DraftInvoice
INNER JOIN
        dbo.Customer ON dbo.DraftInvoice.CustomerId = dbo.Customer.Id
LEFT JOIN
		dbo.BillingPeriod ON dbo.DraftInvoice.BillingPeriodId = dbo.BillingPeriod.Id
INNER JOIN Lookup.CustomerAccountStatus ON dbo.Customer.AccountStatusId = Lookup.CustomerAccountStatus.Id
INNER JOIN Lookup.CustomerStatus ON dbo.Customer.StatusId = Lookup.CustomerStatus.Id

GO

