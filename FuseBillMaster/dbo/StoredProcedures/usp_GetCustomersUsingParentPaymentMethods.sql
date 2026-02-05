CREATE PROCEDURE [dbo].[usp_GetCustomersUsingParentPaymentMethods]
	 @AccountId BIGINT
AS

SELECT
	Id
INTO #CustomersWithParents
FROM Customer
WHERE AccountId = @AccountId
	AND ParentId IS NOT NULL

SELECT
	c.Id
	,9 as EntityType
	,pm.CustomerId as ParentId
	,pm.Id as PaymentMethodId
INTO #CustomersWithParentPaymentMethods
FROM #CustomersWithParents c
INNER JOIN CustomerBillingSetting cbs ON c.Id = cbs.Id
INNER JOIN PaymentMethod pm ON pm.Id = cbs.DefaultPaymentMethodId
left join PaymentMethodSharing pms on pms.customerId = c.id
WHERE cbs.DefaultPaymentMethodId IS NOT NULL
	AND c.Id != pm.CustomerId
	and pms.Sharing is null

INSERT INTO #CustomersWithParentPaymentMethods
SELECT
	c.Id
	,87 as EntityType
	,pm.CustomerId as ParentId
	,pm.Id as PaymentMethodId
FROM #CustomersWithParents c
INNER JOIN BillingPeriodDefinition bpd ON c.Id = bpd.CustomerId
INNER JOIN PaymentMethod pm ON pm.Id = bpd.PaymentMethodId
WHERE bpd.PaymentMethodId IS NOT NULL
	AND c.Id != pm.CustomerId

SELECT
	Id
	,EntityType
	,ParentId
	,PaymentMethodId
FROM #CustomersWithParentPaymentMethods

DROP TABLE #CustomersWithParents
DROP TABLE #CustomersWithParentPaymentMethods

GO

