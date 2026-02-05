CREATE   VIEW [dbo].[vw_InvoiceSummary]
AS
WITH SettledInvoices AS 
(
	SELECT pn.InvoiceId
    FROM dbo.PaymentNote AS pn 
	INNER JOIN dbo.Payment AS p ON p.Id = pn.PaymentId 
	INNER JOIN dbo.PaymentActivityJournal AS paj ON paj.Id = p.PaymentActivityJournalId AND paj.SettlementStatusId = 2
    GROUP BY pn.InvoiceId
)
    SELECT 
	c.Id AS CustomerId, 
	c.Reference, 
	c.CurrencyId, 
	i.AccountId, 
	c.CompanyName, 
	c.TitleId, 
	c.FirstName, 
	c.MiddleName, 
	c.LastName, 
	c.IsParent AS CustomerIsParent, 
	Lookup.CustomerAccountStatus.[Name] AS AccountingStatus, 
    Lookup.CustomerStatus.[Name] AS CustomerStatus, 
	c.Suffix, 
	c.ParentId AS CustomerParentId, 
	i.InvoiceNumber, 
	i.PoNumber, 
	i.TotalInstallments, 
	ps.InstallmentNumber, 
	ps.StatusId, 
	i.SumOfCharges, 
	i.SumOfDiscounts, 
	i.SumOfTaxes, 
    lc.IsoName AS Currency, 
	ps.DueDate, 
	i.PostedTimestamp, 
	i.EffectiveTimestamp, 
	i.Id, 
	ps.OutstandingBalance, 
	ps.Amount as PaymentScheduleAmount,
	i.LastJournalTimestamp AS ModifiedTimestamp, 
	COALESCE (i.SumOfPayments - i.SumOfRefunds, 0) AS TotalPayments, 
    i.SumOfCreditNotes AS TotalCreditNotes, 
	COALESCE (i.SumOfCharges - i.SumOfDiscounts + i.SumOfTaxes, 0) AS InvoiceAmount, 
	COALESCE (i.SumOfWriteOffs, 0) AS Writeoffs, i.DraftInvoiceId, 
	CONVERT(VARCHAR(50), i.AvalaraId) AS AvalaraId, 
	CONVERT(VARCHAR(50), i.QuickBooksId) AS QuickBooksId, 
	i.QuickBooksAttemptNumber,
	NULL AS SageIntacctId, 
	0 AS SageIntacctAttemptNumber,
	COALESCE (CONVERT(BIT, CASE WHEN si.InvoiceId IS NOT NULL THEN 1 ELSE 0 END), NULL) AS Unsettled, 
	i.HideOnSSP
    FROM dbo.Invoice AS i 
	INNER JOIN dbo.Customer AS c ON i.CustomerId = c.Id 
	INNER JOIN dbo.PaymentSchedule AS ps ON ps.InvoiceId = i.Id 
	INNER JOIN Lookup.Currency AS lc ON lc.Id = c.CurrencyId 
	INNER JOIN Lookup.CustomerAccountStatus ON c.AccountStatusId = Lookup.CustomerAccountStatus.Id 
	INNER JOIN Lookup.CustomerStatus ON c.StatusId = Lookup.CustomerStatus.Id 
	LEFT OUTER JOIN SettledInvoices AS si ON si.InvoiceId = i.Id

GO

