CREATE PROCEDURE [dbo].[usp_GetInvoicesForCancellation]
	@invoiceIds AS dbo.IDList READONLY,
	@subscriptionId as bigint, 
	@excludeZeroDollarCharges bit
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

declare @invoices table
(
InvoiceId bigint
)

INSERT INTO @invoices (InvoiceId)
SELECT ids.Id
FROM @invoiceIds ids

SELECT i.* FROM [dbo].[Invoice] i
INNER JOIN @invoices ii ON i.Id = ii.InvoiceId

SELECT ic.* FROM [dbo].[InvoiceCustomer] ic
INNER JOIN @invoices ii ON ic.InvoiceId = ii.InvoiceId

SELECT ij.* FROM [dbo].[InvoiceJournal] ij
INNER JOIN @invoices ii ON ij.InvoiceId = ii.InvoiceId
WHERE ij.IsActive = 1

SELECT c.*
	, t.*
	, c.EarningTimingTypeId as EarningTimingType
	, c.EarningTimingIntervalId as EarningTimingInterval
	, t.TransactionTypeId as TransactionType
FROM [dbo].[Charge] c
Inner join SubscriptionProductCharge spc on c.Id = spc.Id
inner join SubscriptionProduct sp on sp.Id = spc.SubscriptionProductId and sp.SubscriptionId = @subscriptionId
INNER JOIN @invoices ii ON c.InvoiceId = ii.InvoiceId
INNER JOIN [Transaction] t ON t.Id = c.Id
WHERE t.Amount > 0 OR @excludeZeroDollarCharges = 0

SELECT spc.* FROM [dbo].[SubscriptionProductCharge] spc
inner join [SubscriptionProduct] sp on spc.SubscriptionProductId = sp.Id and sp.SubscriptionId = @subscriptionId
INNER JOIN [dbo].[Charge] c ON spc.Id = c.Id
INNER JOIN @invoices ii ON c.InvoiceId = ii.InvoiceId

SELECT ps.* 
	,ps.StatusId as [Status]
FROM [dbo].[PaymentSchedule] ps
INNER JOIN @invoices ii ON ps.InvoiceId = ii.InvoiceId

SELECT psj.*
	, psj.StatusId as [Status]
FROM [PaymentSchedule] ps
INNER JOIN [dbo].[PaymentScheduleJournal] psj ON ps.Id = psj.PaymentScheduleId AND psj.IsActive = 1
INNER JOIN @invoices ii ON ps.InvoiceId = ii.InvoiceId


SELECT cle.*
FROM [dbo].ChargeLastEarning cle
INNER JOIN [dbo].[Charge] c ON c.Id = cle.Id
Inner join SubscriptionProductCharge spc on c.Id = spc.Id
inner join SubscriptionProduct sp on sp.Id = spc.SubscriptionProductId and sp.SubscriptionId = @subscriptionId
INNER JOIN @invoices ii ON c.InvoiceId = ii.InvoiceId

SELECT d.*
	, t.*
	, d.DiscountTypeId as DiscountType
	, t.TransactionTypeId as TransactionType
FROM [dbo].[Discount] d
INNER JOIN [dbo].[Charge] c ON c.Id = d.ChargeId
Inner join SubscriptionProductCharge spc on c.Id = spc.Id
inner join SubscriptionProduct sp on sp.Id = spc.SubscriptionProductId and sp.SubscriptionId = @subscriptionId
INNER JOIN [Transaction] t ON t.Id = d.Id
INNER JOIN @invoices ii ON c.InvoiceId = ii.InvoiceId


SELECT e.*
	, t.*
	, t.TransactionTypeId as TransactionType
FROM [dbo].[Earning] e
INNER JOIN [dbo].[Charge] c ON c.Id = e.ChargeId
Inner join SubscriptionProductCharge spc on c.Id = spc.Id
inner join SubscriptionProduct sp on sp.Id = spc.SubscriptionProductId and sp.SubscriptionId = @subscriptionId
INNER JOIN [Transaction] t ON t.Id = e.Id
INNER JOIN @invoices ii ON c.InvoiceId = ii.InvoiceId

SELECT re.*
	, t.*
	, t.TransactionTypeId as TransactionType
FROM [dbo].[ReverseEarning] re
INNER JOIN [Transaction] t ON t.Id = re.Id
INNER JOIN [dbo].[ReverseCharge] rc ON rc.Id = re.ReverseChargeId
INNER JOIN [dbo].[Charge] c ON c.Id = rc.OriginalChargeId
Inner join SubscriptionProductCharge spc on c.Id = spc.Id
inner join SubscriptionProduct sp on sp.Id = spc.SubscriptionProductId and sp.SubscriptionId = @subscriptionId
INNER JOIN @invoices ii ON c.InvoiceId = ii.InvoiceId

SELECT rd.*
	, t.*
	, t.TransactionTypeId as TransactionType
FROM [dbo].[ReverseDiscount] rd
INNER JOIN [Transaction] t ON t.Id = rd.Id
INNER JOIN [dbo].[Discount] d ON d.Id = rd.OriginalDiscountId
INNER JOIN [dbo].[Charge] c ON c.Id = d.ChargeId
Inner join SubscriptionProductCharge spc on c.Id = spc.Id
inner join SubscriptionProduct sp on sp.Id = spc.SubscriptionProductId and sp.SubscriptionId = @subscriptionId
INNER JOIN @invoices ii ON c.InvoiceId = ii.InvoiceId

SELECT rc.*
	, t.*
	, t.TransactionTypeId as TransactionType
FROM [dbo].[ReverseCharge] rc
INNER JOIN [dbo].[Charge] c ON c.Id = rc.OriginalChargeId
INNER JOIN [Transaction] t ON t.Id = rc.Id
Inner join SubscriptionProductCharge spc on c.Id = spc.Id
inner join SubscriptionProduct sp on sp.Id = spc.SubscriptionProductId and sp.SubscriptionId = @subscriptionId
INNER JOIN @invoices ii ON c.InvoiceId = ii.InvoiceId


END

GO

