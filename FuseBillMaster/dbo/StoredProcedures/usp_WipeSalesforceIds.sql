CREATE procedure [dbo].[usp_WipeSalesforceIds]
	@CustomerId bigint,
	@AccountId bigint
AS

SET NOCOUNT ON

UPDATE s
SET s.SalesforceId = null
from Subscription as s
inner join Customer c on s.CustomerId = c.Id
WHERE s.CustomerId = @CustomerId and c.AccountId = @AccountId

UPDATE Invoice
SET SalesforceId = null
WHERE CustomerId = @CustomerId and AccountId = @AccountId

UPDATE p
SET p.SalesforceId = null
from Purchase as p
inner join Customer c on p.CustomerId = c.Id
WHERE p.CustomerId = @CustomerId and c.AccountId = @AccountId

UPDATE sp
SET sp.SalesforceId = null
from SubscriptionProduct as sp
INNER JOIN Subscription s ON s.Id = sp.SubscriptionId
inner join Customer c on s.CustomerId = c.Id
WHERE s.CustomerId = @CustomerId and c.AccountId = @AccountId

UPDATE Customer
	SET SalesforceId = null
WHERE Id = @CustomerId and AccountId = @AccountId

--Delete from the Salesforce Sync Status

	--Customer
	DELETE FROM SalesforceSyncStatus
	WHERE AccountId = @AccountId and EntityTypeId = 3 and EntityId = @CustomerId

	--Invoice
	DELETE ss FROM SalesforceSyncStatus ss
	inner join Invoice i on i.Id = ss.EntityId
	WHERE ss.AccountId = @AccountId and ss.EntityTypeId = 11 and i.CustomerId = @CustomerId

	--Subscription
	DELETE ss FROM SalesforceSyncStatus ss
	inner join Subscription s on s.Id = ss.EntityId
	WHERE ss.AccountId = @AccountId and ss.EntityTypeId = 7 and s.CustomerId = @CustomerId

	--Subscription product
	DELETE ss FROM SalesforceSyncStatus ss
	inner join SubscriptionProduct sp on sp.Id = ss.EntityId
	inner join Subscription s on s.Id = sp.SubscriptionId
	WHERE ss.AccountId = @AccountId and ss.EntityTypeId = 14 and s.CustomerId = @CustomerId

	--Purchase
	DELETE ss FROM SalesforceSyncStatus ss
	inner join Purchase p on p.Id = ss.EntityId
	WHERE ss.AccountId = @AccountId and ss.EntityTypeId = 21 and p.CustomerId = @CustomerId


Select @CustomerId AS CustomerId

SET NOCOUNT OFF

GO

