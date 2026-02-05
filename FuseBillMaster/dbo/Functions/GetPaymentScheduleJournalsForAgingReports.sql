CREATE FUNCTION [dbo].[GetPaymentScheduleJournalsForAgingReports]
(	
	--required
	@CustomerIds dbo.IdList READONLY,
	@AccountId BIGINT,
	@ReportDate datetime
	
)
RETURNS TABLE 
AS
RETURN 
  
--Get all payment schedules for the account, no way to know yet which are not needed
WITH UnfilteredPaymentSchedules AS( SELECT   
  ps.Id
 ,ps.InvoiceId
 ,c.Id as CustomerId
FROM  
 PaymentSchedule ps  
 INNER JOIN Invoice i on ps.InvoiceId = i.Id  
 INNER JOIN @CustomerIds c ON c.id = i.CustomerId      
WHERE      
   i.AccountId = @AccountId  
   )
  
--Get the most recent payment schedule journals for each payment schedule
, CTE_RankedJournals AS (  
SELECT
	ROW_NUMBER() OVER (PARTITION BY psj.PaymentScheduleId ORDER BY psj.CreatedTimestamp DESC, psj.IsActive DESC) AS [RowNumber]  
  , psj.PaymentScheduleId  
  , psj.OutstandingBalance  
  , cast(datediff(hour,psj.DueDate,@ReportDate) AS DECIMAL(20,2))/24 AS DaysOld  
  , psj.StatusId  
  ,psj.DueDate  
  ,ups.InvoiceId 
  ,ups.CustomerId  
 FROM  
  PaymentScheduleJournal psj  
  INNER JOIN UnfilteredPaymentSchedules ups ON ups.Id = psj.PaymentScheduleId
 WHERE  
  psj.CreatedTimestamp < @ReportDate  
  )

SELECT cte.PaymentScheduleId, cte.OutstandingBalance, cte.DaysOld, cte.StatusId, cte.DueDate, cte.InvoiceId, 1 as [PaymentScheduleCount]
		,i.InvoiceNumber, i.TermId, i.PostedTimestamp, cte.CustomerId, i.BillingPeriodId
FROM CTE_RankedJournals  cte
--Only need invoice information for the most recent journal, so shortcut the join
INNER JOIN Invoice i ON cte.RowNumber = 1 AND cte.InvoiceId = i.Id
WHERE cte.[RowNumber] = 1  
--Need all statuses in case there are multiple payment schedules on an invoice
 --AND cte.StatusId NOT IN (4,5,7)

GO

