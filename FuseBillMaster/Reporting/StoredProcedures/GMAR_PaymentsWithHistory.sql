CREATE   PROCEDURE [Reporting].[GMAR_PaymentsWithHistory] 
	@AccountId BIGINT 
	,@StartDate DATETIME 
	,@EndDate DATETIME 
AS
DECLARE @TimezoneId int

select @EndDate = dbo.fn_GetUtcTime(@EndDate,TimezoneId)
,@StartDate = dbo.fn_GetUtcTime(@StartDate,TimezoneId)
,@TimezoneId = TimezoneId
from AccountPreference 
where Id = @AccountId

;WITH CustomerSubscriptions AS (
SELECT
	c.Id as FusebillId
	,ISNULL(so.Name, s.PlanName) as SubscriptionName
	,STUFF((SELECT ', ' + PlanProductName
			FROM SubscriptionProduct sp
			WHERE sp.SubscriptionId = s.Id
				AND sp.Included = 1 AND sp.IsRecurring = 1
				FOR XML PATH(''), TYPE)
        .value('.','NVARCHAR(MAX)'),1,2,' ') PlanProductName
	,DATEDIFF(MONTH, s.ActivationTimestamp,GETUTCDATE()) as MonthsActive
FROM Subscription s
LEFT JOIN SubscriptionOverride so ON s.Id = so.Id
INNER JOIN Customer c ON c.Id = s.CustomerId
WHERE c.AccountId = @AccountId
	AND s.StatusId = 2
)
,Customers AS 
(
SELECT
	cs.FusebillId
	,STUFF((SELECT DISTINCT ', ' + SubscriptionName FROM CustomerSubscriptions css WHERE css.FusebillId = cs.FusebillId FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)'),1,2,' ') SubscriptionName
	,STUFF((SELECT DISTINCT ', ' + PlanProductName FROM CustomerSubscriptions css WHERE css.FusebillId = cs.FusebillId FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)'),1,2,' ') PlanProductName
	,STUFF((SELECT DISTINCT ', ' + CONVERT(varchar,MonthsActive) FROM CustomerSubscriptions css WHERE css.FusebillId = cs.FusebillId FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)'),1,2,' ') MonthsActive
FROM CustomerSubscriptions cs
),
CustomerSubscription AS
(
	SELECT DISTINCT
		FusebillId
		,SubscriptionName
		,PlanProductName
		,MonthsActive
	FROM Customers
)


,PaymentHistory AS
(SELECT
	paj.Id
	,COUNT(*) OVER (PARTITION BY CustomerId ORDER BY CustomerId,paj.CreatedTimestamp) AS PaymentCount
	,SUM(Amount) OVER (PARTITION BY CustomerId ORDER BY CustomerId,paj.CreatedTimestamp) AS PaymentAmount
FROM PaymentActivityJournal paj
INNER JOIN Customer c ON c.Id = paj.CustomerId
WHERE c.AccountId = @AccountId
	AND paj.PaymentActivityStatusId NOT IN (2,3)
	AND paj.PaymentTypeId = 2
)

,RefundHistory AS 
(SELECT
	c.Id
	,COUNT(*) as NumberOfRefunds
	,-SUM(t.Amount) as SumOfRefunds
FROM Customer c
INNER JOIN [Transaction] t ON t.CustomerId = c.Id
INNER JOIN Refund r ON r.Id = t.Id
WHERE c.AccountId = @AccountId
GROUP BY c.Id
)

SELECT
	paj.Id
	,c.Id as FusebillId
	,c.Reference as CustomerId
	,c.FirstName
	,c.LastName
	,ISNULL(c.CompanyName,'') as CompanyName
	,ISNULL(pm.AccountType,pmt.Name) as PaymentType
	,ISNULL(p.Reference,'') as Reference
	,cu.IsoName as PaymentCurrency
	,pas.Name as PaymentResult
	,paj.Amount as PaymentAmount
	,ISNULL(paj.AuthorizationCode,'') as GatewayResponseCode
	,ISNULL(paj.AuthorizationResponse,'') as GatewayResponseReason
	,paj.CreatedTimestamp
	,ISNULL(cs.SubscriptionName,'') as SubscriptionName
	,ISNULL(cs.PlanProductName,'') as PlanProductName
	,ISNULL(cs.MonthsActive,'') as MonthsActiveAtTimeOfPayment
	,ph.PaymentCount as NumberOfPayments
	,ph.PaymentAmount as SumOfPayments
	,ISNULL(rh.NumberOfRefunds,0) as NumberOfRefunds
	,ISNULL(rh.SumOfRefunds,0) as SumOfRefunds
FROM PaymentActivityJournal paj
INNER JOIN PaymentHistory ph ON ph.Id = paj.Id
LEFT JOIN PaymentMethod pm ON pm.Id = paj.PaymentMethodId
INNER JOIN Payment p ON p.PaymentActivityJournalId = paj.Id
INNER JOIN Customer c ON c.Id = paj.CustomerId
INNER JOIN Lookup.Currency cu ON c.CurrencyId = cu.Id
INNER JOIN Lookup.PaymentActivityStatus pas on pas.Id = paj.PaymentActivityStatusId
INNER JOIN Lookup.PaymentMethodType pmt ON pmt.Id = paj.PaymentMethodTypeId
LEFT JOIN CustomerSubscription cs ON c.Id = cs.FusebillId
LEFT JOIN RefundHistory rh ON rh.Id = c.Id
WHERE c.AccountId = @AccountId
	AND paj.PaymentTypeId = 2
	AND paj.CreatedTimestamp >= @StartDate
	AND paj.CreatedTimestamp < @EndDate

UNION all

SELECT
	paj.Id
	,c.Id as FusebillId
	,c.Reference as CustomerId
	,c.FirstName
	,c.LastName
	,ISNULL(c.CompanyName,'') as CompanyName
	,ISNULL(pm.AccountType,pmt.Name) as PaymentType
	,ISNULL(p.Reference,'') as Reference
	,cu.IsoName as PaymentCurrency
	,pas.Name as PaymentResult
	,-paj.Amount as PaymentAmount
	,ISNULL(paj.AuthorizationCode,'') as GatewayResponseCode
	,ISNULL(paj.AuthorizationResponse,'') as GatewayResponseReason
	,paj.CreatedTimestamp
	,ISNULL(cs.SubscriptionName,'') as SubscriptionName
	,ISNULL(cs.PlanProductName,'') as PlanProductName
	,ISNULL(cs.MonthsActive,'') as MonthsActiveAtTimeOfPayment
	,ph.PaymentCount as NumberOfPayments
	,ph.PaymentAmount as SumOfPayments
	,ISNULL(rh.NumberOfRefunds,0) as NumberOfRefunds
	,ISNULL(rh.SumOfRefunds,0) as SumOfRefunds
FROM Refund r
INNER JOIN PaymentActivityJournal paj ON paj.Id = r.PaymentActivityJournalId
LEFT JOIN PaymentMethod pm ON pm.Id = paj.PaymentMethodId
INNER JOIN Payment p ON p.Id = r.OriginalPaymentId
INNER JOIN PaymentHistory ph ON ph.Id = p.PaymentActivityJournalId
INNER JOIN Customer c ON c.Id = paj.CustomerId
INNER JOIN Lookup.Currency cu ON c.CurrencyId = cu.Id
INNER JOIN Lookup.PaymentActivityStatus pas on pas.Id = paj.PaymentActivityStatusId
INNER JOIN Lookup.PaymentMethodType pmt ON pmt.Id = paj.PaymentMethodTypeId
LEFT JOIN CustomerSubscription cs ON c.Id = cs.FusebillId
LEFT JOIN RefundHistory rh ON rh.Id = c.Id
WHERE c.AccountId = @AccountId
	AND paj.PaymentTypeId = 3
	AND paj.CreatedTimestamp >= @StartDate
	AND paj.CreatedTimestamp < @EndDate

GO

