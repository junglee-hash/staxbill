CREATE   PROCEDURE [dbo].[usp_GetInvoicesWithPaymentSchedules]  
 @invoiceIds AS dbo.IDList READONLY
AS  
BEGIN  
-- SET NOCOUNT ON added to prevent extra result sets from  
-- interfering with SELECT statements.  
SET NOCOUNT ON;  
  
DECLARE @invoices TABLE  
(  
 InvoiceId BIGINT
)  
  
INSERT INTO @invoices (InvoiceId)  
SELECT ids.Id 
FROM @invoiceIds ids 
  

SELECT i.* FROM [dbo].[Invoice] i  
INNER JOIN @invoices ii ON i.Id = ii.InvoiceId  
  
  
SELECT ps.*
	,ps.StatusId as [Status]
FROM [dbo].[PaymentSchedule] ps  
INNER JOIN @invoices ii ON ps.InvoiceId = ii.InvoiceId  

  
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


END

GO

