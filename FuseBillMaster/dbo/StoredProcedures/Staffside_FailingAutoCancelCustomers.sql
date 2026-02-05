CREATE   PROCEDURE dbo.Staffside_FailingAutoCancelCustomers
AS
BEGIN

DECLARE @RunTimeStamp DATETIME = GETUTCDATE()


;WITH CTE AS (
SELECT        
	c.Id, 
	c.StatusId AS AccountStatusId, 
	c.LastStatusJournalTimestamp AS SuspendedDay, 
	cbs.[CustomerAutoCancel], 
	abp.[AccountAutoCancel],
	c.AccountId as [AccountId],
	abp.AutoCancelTypeId
FROM          
	--All from customer  
	dbo.Customer AS c 
	INNER JOIN Account a ON a.Id = c.AccountId
	--Get their billing settings
	INNER JOIN dbo.CustomerBillingSetting AS cbs ON cbs.Id = c.Id 
	INNER JOIN dbo.AccountBillingPreference AS abp ON abp.Id = c.AccountId
WHERE        
	a.IncludeInAutomatedProcesses = 1 AND
	--When the customer is status suspended
	(c.StatusId = 5) 
	AND 
	--And the account status is Poor Standing
	(c.AccountStatusId = 2) 
	AND 
	--And it has been x days since the suspended date
	(COALESCE (cbs.[CustomerAutoCancel], abp.[AccountAutoCancel]) <= DATEDIFF(day, c.LastStatusJournalTimestamp, @RunTimeStamp))
	AND COALESCE (cbs.[CustomerAutoCancel], abp.[AccountAutoCancel]) + 7 < DATEDIFF(day, c.LastStatusJournalTimestamp, @RunTimeStamp)
	)
SELECT AccountId, a.CompanyName, CTE.Id as StaxBillId, AccountStatusId, SuspendedDay, CustomerAutoCancel, AccountAutoCancel  FROM CTE
INNER JOIN Account a ON CTE.AccountId = a.Id
WHERE (AutoCancelTypeId = 1  --customer cancel
	OR (AutoCancelTypeId = 2 -- subscription cancel
		AND EXISTS ( 
			SELECT Id from Subscription s 
			where s.CustomerId = CTE.Id 
			AND s.IsDeleted = 0
			AND s.StatusId not in (7,3) --migrated and cancelled
		) 
	)
)

END

GO

