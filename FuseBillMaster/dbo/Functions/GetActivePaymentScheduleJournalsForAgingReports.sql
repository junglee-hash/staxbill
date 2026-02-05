
CREATE   FUNCTION [dbo].[GetActivePaymentScheduleJournalsForAgingReports]
(	
	--required
	@CustomerIds dbo.IdList READONLY,
	@AccountId BIGINT,
	@ReportDate DATETIME
	
)
RETURNS TABLE 
AS
RETURN 

SELECT 
  ps.Id AS PaymentScheduleId  
  , ps.OutstandingBalance  
  , CAST(DATEDIFF(HOUR,ps.DueDate,@ReportDate) AS DECIMAL(20,2))/24 AS DaysOld  
  , ps.StatusId  
  ,ps.DueDate  
  ,ps.InvoiceId
  ,1 AS [PaymentScheduleCount]  
  ,i.InvoiceNumber
  ,i.TermId
  ,i.PostedTimestamp
  ,i.CustomerId  
  ,i.BillingPeriodId
 FROM  PaymentSchedule ps
  INNER JOIN Invoice i ON i.Id = ps.InvoiceId
  INNER JOIN @CustomerIds c ON c.Id = i.CustomerId
 WHERE  
  --Need all statuses in case there are multiple payment schedules on an invoice
  --since we're already filtered down to customers which should be on the account,
  --this accountId match isn't strictly needed, it is here for performance:
  i.AccountId = @AccountId

GO

