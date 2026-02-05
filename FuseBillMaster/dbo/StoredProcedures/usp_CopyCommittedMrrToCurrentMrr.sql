CREATE   procedure [dbo].[usp_CopyCommittedMrrToCurrentMrr]
	@customerId BIGINT
AS

SET NOCOUNT ON

UPDATE sp SET
	CurrentMrr = sp.MonthlyRecurringRevenue,
	CurrentNetMrr = sp.NetMRR
FROM SubscriptionProduct sp
INNER JOIN Subscription s ON s.Id = sp.SubscriptionId
WHERE s.CustomerId = @customerId

UPDATE Subscription SET
	CurrentMrr = MonthlyRecurringRevenue,
	CurrentNetMrr = NetMRR
WHERE CustomerId = @customerId

UPDATE Customer SET
	CurrentMrr = MonthlyRecurringRevenue,
	CurrentNetMrr = NetMRR
FROM Customer
WHERE Id = @customerId

SET NOCOUNT OFF

GO

