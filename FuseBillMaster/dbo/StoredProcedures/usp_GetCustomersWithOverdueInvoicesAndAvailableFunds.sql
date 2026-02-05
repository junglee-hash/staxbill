CREATE     PROCEDURE [dbo].[usp_GetCustomersWithOverdueInvoicesAndAvailableFunds]
AS
BEGIN

;WITH TransactionsWithUnallocatedAmount AS
(
	SELECT
		Id
	FROM Payment
	WHERE UnallocatedAmount > 0

	UNION

	SELECT
		Id
	FROM Credit
	WHERE UnallocatedAmount > 0

	UNION

	SELECT
		Id
	FROM OpeningBalance
	WHERE UnallocatedAmount > 0
)
SELECT DISTINCT
	t.CustomerId
	,t.AccountId
INTO #CustomersWithAvailableFunds
FROM TransactionsWithUnallocatedAmount tu
INNER JOIN [Transaction] t ON t.Id = tu.Id


SELECT c.CustomerId
	FROM #CustomersWithAvailableFunds c
	INNER JOIN Account a ON a.Id = c.AccountId
	INNER JOIN Invoice i ON c.CustomerId = i.CustomerId
	INNER JOIN PaymentSchedule ps ON i.Id = ps.InvoiceId AND ps.StatusId = 3 --overdue
	WHERE a.IncludeInAutomatedProcesses = 1
	GROUP BY c.CustomerId


DROP TABLE #CustomersWithAvailableFunds
END

GO

