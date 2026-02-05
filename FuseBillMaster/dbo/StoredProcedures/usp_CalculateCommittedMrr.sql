
CREATE procedure [dbo].[usp_CalculateCommittedMrr]
	@customerId BIGINT
AS

SET NOCOUNT ON

SELECT 
	s.Id AS subscriptionId, 
	SUM(sp.MonthlyRecurringRevenue) AS monthlyRecurringRevenue, 
	SUM(sp.NetMrr) AS netMRR
INTO #subscriptionMRRData
FROM subscription s 
INNER JOIN subscriptionProduct sp ON s.Id = sp.SubscriptionId
WHERE s.CustomerId = @customerId
GROUP by s.Id

UPDATE Subscription
	SET 
	MonthlyRecurringRevenue = d.monthlyRecurringRevenue,
	NetMrr = d.netMRR
FROM
Subscription INNER JOIN #subscriptionMRRData d ON d.subscriptionId = Subscription.Id

DECLARE @newNetMrr MONEY
DECLARE @newMonthlyRecurringRevenue MONEY

SET @newNetMrr = (SELECT SUM(netMRR) FROM #subscriptionMRRData)
SET @newMonthlyRecurringRevenue = (SELECT SUM(monthlyRecurringRevenue) FROM #subscriptionMRRData)

UPDATE Customer
	SET
	MonthlyRecurringRevenue = @newMonthlyRecurringRevenue,
	NetMRR = @newNetMrr
Where Id = @customerId

DROP TABLE #subscriptionMRRData

SET NOCOUNT OFF

GO

