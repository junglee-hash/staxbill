
CREATE VIEW [dbo].[vw_IntegrationSyncInvoiceData]
AS

SELECT   DISTINCT  TOP (100) PERCENT 
sfbr.IntegrationSynchBatchId as BatchId
,dbo.Invoice.SalesforceId
, dbo.Customer.SalesforceId AS AccountSalesforceId
,dbo.Invoice.NetsuiteId
,dbo.Customer.NetsuiteId as CustomerNetsuiteId
, dbo.Invoice.Id
, InvoiceNumber
, CASE WHEN TotalInstallments = 1 THEN  PSJ.DueDate END AS DueDate
, dbo.Invoice.PostedTimestamp
, JR.SumOfCharges
, PSJ.OutstandingBalance
, ISNULL(JR.SumOfPayments - JR.SumOfRefunds, 0) AS TotalPayments
,  JR.SumOfCreditNotes
, ISNULL(JR.SumOfCharges - JR.SumOfDiscounts + JR.SumOfTaxes, 0) AS Amount
, ISNULL(JR.SumOfWriteOffs, 0) AS TotalWriteoffs
,  istatus.Name as Status
, PS.InstallmentNumber as Installments
, dbo.Account.Id as AccountId
, CASE WHEN TotalInstallments = 1 THEN CONVERT(nvarchar,InvoiceNumber) ELSE CONVERT(nvarchar,InvoiceNumber) + '-' + CONVERT(nvarchar,PS.InstallmentNumber) END As InvoiceName

     FROM dbo.Invoice 
	 INNER JOIN dbo.IntegrationSynchBatchRecord AS sfbr ON sfbr.EntityId = dbo.Invoice.Id 
	 INNER JOIN dbo.IntegrationSynchBatch AS sfb ON sfbr.IntegrationSynchBatchId = sfb.Id 
	 INNER JOIN dbo.Customer ON dbo.Invoice.CustomerId = dbo.Customer.Id 
	 INNER JOIN dbo.Account ON dbo.Account.Id = dbo.Customer.AccountId 
	 INNER JOIN dbo.InvoiceJournal AS JR ON dbo.Invoice.Id = JR.InvoiceId and JR.IsActive = 1
	 INNER JOIN dbo.PaymentSchedule AS PS ON PS.InvoiceId = dbo.Invoice.Id 
	 INNER JOIN dbo.PaymentScheduleJournal AS PSJ ON PSJ.PaymentScheduleId = PS.Id AND PSJ.IsActive = 1
	 INNER JOIN Lookup.InvoiceStatus AS istatus on istatus.Id = PSJ.StatusId 
	WHERE  (sfbr.EntityTypeId = 11) AND (sfb.StatusId NOT IN (4, 5)) ORDER BY dbo.Invoice.Id

GO

