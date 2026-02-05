
CREATE PROCEDURE [dbo].[usp_GetNextRenewingSubscriptionCustomerOwned]
	@accountId bigint
	,@customerId bigint
	,@excludeSubscriptionIds AS dbo.IDList READONLY
AS 

SELECT top(1)
	c.AccountId, 
	s.Id as SubscriptionId, 
	c.Id AS CustomerId,
	c.Id as InvoiceOwnerCustomerId,
	CASE WHEN s.StatusId = 2 OR s.StatusId = 6 THEN bp.RechargeDate ELSE NULL END AS NextBillingDate
FROM 
	Subscription s INNER JOIN
	Customer c ON s.CustomerId = c.Id
	inner join BillingPeriodDefinition bpd on bpd.Id = s.BillingPeriodDefinitionId 
	inner join BillingPeriod bp on bpd.Id = bp.BillingPeriodDefinitionId and bp.PeriodStatusId = 1
WHERE 
	c.AccountId = @AccountId AND
	s.[IsDeleted] = 0 AND
	s.[StatusId] IN (2, 6) AND NOT EXISTS (SELECT 1 FROM @excludeSubscriptionIds ex WHERE ex.Id = s.Id) AND
	s.CustomerId = @customerId AND
	bp.CustomerId = @customerId
ORDER BY 
	NextBillingDate ASC

GO

