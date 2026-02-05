

CREATE     PROCEDURE [dbo].[usp_GetInvoiceForSalesforce]  
 @invoiceId BIGINT
AS  
BEGIN  
-- SET NOCOUNT ON added to prevent extra result sets from  
-- interfering with SELECT statements.  
SET NOCOUNT ON;  
  
SELECT i.* FROM [dbo].[Invoice] i  
WHERE i.Id = @invoiceId
  
SELECT ps.*
	,ps.StatusId as [Status]
FROM [dbo].[PaymentSchedule] ps  
WHERE ps.InvoiceId = @invoiceId
 
SELECT psj.Id  
 , psj.PaymentScheduleId  
 , psj.DueDate  
 , psj.StatusId as [Status]  
 , psj.OutstandingBalance  
 , psj.CreatedTimestamp  
 , psj.IsActive  
FROM [PaymentSchedule] ps  
INNER JOIN [dbo].[PaymentScheduleJournal] psj ON ps.Id = psj.PaymentScheduleId AND psj.IsActive = 1  
WHERE ps.InvoiceId = @invoiceId
  
SELECT ij.* FROM [dbo].[InvoiceJournal] ij  
WHERE ij.IsActive = 1  
AND ij.InvoiceId = @invoiceId

SELECT c.*
	, t.*
	, c.EarningTimingTypeId as EarningTimingType
	, c.EarningTimingIntervalId as EarningTimingInterval
	, t.TransactionTypeId as TransactionType
FROM [dbo].[Charge] c
INNER JOIN [Transaction] t ON t.Id = c.Id
WHERE t.Amount > 0 AND c.InvoiceID = @invoiceId

SELECT tax.*
	, t.*
	, t.TransactionTypeId as TransactionType
FROM [dbo].[Tax] tax
INNER JOIN [Transaction] t ON t.Id = tax.Id
WHERE t.Amount > 0 AND tax.InvoiceID = @invoiceId

SELECT d.*
	, t.*
	, d.DiscountTypeId as DiscountType
	, t.TransactionTypeId as TransactionType
FROM [dbo].[Discount] d
INNER JOIN [dbo].[Charge] c ON c.Id = d.ChargeId
INNER JOIN [Transaction] t ON t.Id = d.Id
WHERE t.Amount > 0 AND c.InvoiceID = @invoiceId

SELECT pn.* 
FROM [dbo].[paymentNote] pn
WHERE pn.InvoiceId = @invoiceId


SELECT rn.* 
FROM [dbo].[refundNote] rn
WHERE rn.InvoiceId = @invoiceId


END

GO

