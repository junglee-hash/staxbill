CREATE Procedure [dbo].[usp_GetCustomersForProjectedInvoices]
	@accountId bigint
AS
SELECT 
	c.Id
	,CASE WHEN sum(isnull(di.CustomerId,0)) = 0 THEN CAST(1 as bit) ELSE CAST(0 as bit) END as NeedsProjected
	,CASE WHEN sum(isnull(p.CustomerId,0)) = 0 THEN CAST(1 as bit) ELSE CAST(0 as bit) END as NeedsCalendar
FROM Customer c
INNER JOIN Subscription s ON c.Id = s.CustomerId
LEFT JOIN DraftInvoice di ON c.Id = di.CustomerId AND di.DraftInvoiceStatusId = 5
LEFT JOIN ProjectedInvoice p ON c.Id = p.CustomerId
WHERE c.AccountId = @accountId
	AND s.StatusId IN (2,4)
GROUP BY c.Id
HAVING (sum(isnull(di.CustomerId,0)) = 0 OR sum(isnull(p.CustomerId,0)) = 0)

GO

