
CREATE PROCEDURE [dbo].[usp_GetInvoicesForAccountList]
	@invoiceIds AS dbo.IDList READONLY
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

declare @invoices table
(
SortOrder INT
,InvoiceId bigint
)


INSERT INTO @invoices (SortOrder,InvoiceId)
select 
ROW_NUMBER() OVER (ORDER BY (SELECT 100)) AS [SortOrder]
,ids.Id
FROM @invoiceIds ids

SELECT i.* FROM [dbo].[Invoice] i
INNER JOIN @invoices ii ON i.Id = ii.InvoiceId
order by ii.SortOrder

SELECT 
	bp.*,
	bp.PeriodStatusId as PeriodStatus
FROM [dbo].[Invoice] i
INNER JOIN @invoices ii ON i.Id = ii.InvoiceId
INNER JOIN BillingPeriod bp ON bp.Id = i.BillingPeriodId

SELECT 
	bpd.*,
	bpd.IntervalId as Interval,
	bpd.TermId as Term,
	bpd.BillingPeriodTypeId as BillingPeriodType
FROM [dbo].[Invoice] i
INNER JOIN @invoices ii ON i.Id = ii.InvoiceId
INNER JOIN BillingPeriodDefinition bpd ON bpd.CustomerId = i.CustomerId

SELECT ic.* FROM [dbo].[InvoiceCustomer] ic
INNER JOIN @invoices ii ON ic.InvoiceId = ii.InvoiceId

SELECT ia.*
	, ia.AddressTypeId as AddressType
FROM [dbo].[InvoiceAddress] ia
INNER JOIN @invoices ii ON ia.InvoiceId = ii.InvoiceId

SELECT ps.* 
	,ps.StatusId as [Status]
FROM [dbo].[PaymentSchedule] ps
INNER JOIN @invoices ii ON ps.InvoiceId = ii.InvoiceId

SELECT ir.*
FROM [dbo].[InvoiceRevision] ir
INNER JOIN @invoices ii ON ir.InvoiceId = ii.InvoiceId

SELECT psj.Id
	, psj.PaymentScheduleId
	, psj.DueDate
	, psj.StatusId as [Status]
	, psj.OutstandingBalance
	, psj.CreatedTimestamp
	, psj.IsActive 
FROM [PaymentSchedule] ps
INNER JOIN [dbo].[PaymentScheduleJournal] psj ON ps.Id = psj.PaymentScheduleId AND psj.IsActive = 1
INNER JOIN @invoices ii ON ps.InvoiceId = ii.InvoiceId

SELECT ij.* FROM [dbo].[InvoiceJournal] ij
INNER JOIN @invoices ii ON ij.InvoiceId = ii.InvoiceId
WHERE ij.IsActive = 1

SELECT c.*
	, c.TitleId as [Title]
	, c.StatusId as [Status]
	, c.AccountStatusId as [AccountStatus]
	, c.NetsuiteEntityTypeId as [NetsuiteEntityType]
	, c.SalesforceAccountTypeId as [SalesforceAccountType]
	, c.SalesforceSynchStatusId as [SalesforceSynchStatus]
FROM Customer c
INNER JOIN Invoice i ON c.Id = i.CustomerId
INNER JOIN @invoices ii ON i.Id = ii.InvoiceId

SELECT cbs.*
	, cbs.TermId as [Term]
	, cbs.IntervalId as [Interval]
	, cbs.CustomerServiceStartOptionId as [CustomerServiceStartOption]
	, cbs.RechargeTypeId as [RechargeType]
	, cbs.HierarchySuspendOptionId as HierarchySuspendOption
FROM CustomerBillingSetting cbs
INNER JOIN Invoice i ON cbs.Id = i.CustomerId
INNER JOIN @invoices ii ON i.Id = ii.InvoiceId

SELECT iis.*  
FROM InvoiceSignature iis
INNER JOIN Invoice i ON iis.Id = i.InvoiceSignatureId
INNER JOIN @invoices ii ON i.Id = ii.InvoiceId

END

GO

