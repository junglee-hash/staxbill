CREATE Procedure [dbo].[usp_StaffsideAccountNetsuiteIds]
	@AccountId bigint
AS

SELECT 
	[Fusebill ID]
	,[Entity Type]
	,[Entity ID]
	,[Netsuite ID]
	,[Details]
from(
	SELECT
		'Customer' as [Entity Type]
		,Id as [Entity ID]
		,NetsuiteId as [Netsuite ID]
		,COALESCE(FirstName + ' ' + LastName, CompanyName,Reference) as [Details]
		,Id as [Fusebill ID]
	FROM Customer
	WHERE AccountId = @AccountId

	UNION ALL

	SELECT
		'Subscription' as [Entity Type]
		,s.Id as [Entity ID]
		,s.NetsuiteId as [Netsuite ID]
		,s.PlanName as [Details]
		,CustomerId as [Fusebill ID]
	FROM Subscription s
	inner join Customer c on c.Id = s.CustomerId
	WHERE  c.AccountId = @AccountId

	UNION ALL

	SELECT
		'Subscription Product' as [Entity Type]
		,sp.Id as [Entity ID]
		,sp.NetsuiteId as [Netsuite ID]
		,sp.PlanProductName as [Details]
		,CustomerId as [Fusebill ID]
	FROM SubscriptionProduct sp
	inner join Subscription s on s.Id = sp.SubscriptionId
	inner join Customer c on c.Id = s.CustomerId
	WHERE  c.AccountId = @AccountId

	UNION ALL

	SELECT
		'Invoice' as [Entity Type]
		,Id as [Entity ID]
		,Concat(NetsuiteId,'-', ErpNetsuiteId) as [Netsuite ID]
		,Concat('', InvoiceNumber) as [Details]
		,CustomerId as [Fusebill ID]
	FROM Invoice
	WHERE AccountId = @AccountId

	UNION ALL

	SELECT 
		'Payment' as [Entity Type]
		, p.Id as [Entity ID]
		, p.NetsuiteId as [Netsuite ID]
		, '' as [Details]
		, t.CustomerId as [Fusebill ID]
	FROM Payment p
	INNER JOIN [Transaction] t ON t.Id = p.Id
	WHERE t.AccountId = @AccountId

	UNION ALL

	SELECT 
		'Refund' as [Entity Type]
		, p.Id as [Entity ID]
		, p.NetsuiteId as [Netsuite ID]
		, '' as [Details]
		, t.CustomerId as [Fusebill ID]
	FROM Refund p
	INNER JOIN [Transaction] t ON t.Id = p.Id
	WHERE t.AccountId = @AccountId

	UNION ALL

	SELECT 
		'Credit' as [Entity Type]
		, p.Id as [Entity ID]
		, p.NetsuiteId as [Netsuite ID]
		, '' as [Details]
		, t.CustomerId as [Fusebill ID]
	FROM Credit p
	INNER JOIN [Transaction] t ON t.Id = p.Id
	WHERE t.AccountId = @AccountId

	UNION ALL

	SELECT 
		'Debit' as [Entity Type]
		, p.Id as [Entity ID]
		, p.NetsuiteId as [Netsuite ID]
		, '' as [Details]
		, t.CustomerId as [Fusebill ID]
	FROM Debit p
	INNER JOIN [Transaction] t ON t.Id = p.Id
	WHERE t.AccountId = @AccountId

	UNION ALL

	SELECT 
		'Write Off' as [Entity Type]
		, p.Id as [Entity ID]
		, p.NetsuiteId as [Netsuite ID]
		, '' as [Details]
		, t.CustomerId as [Fusebill ID]
	FROM WriteOff p
	INNER JOIN [Transaction] t ON t.Id = p.Id
	WHERE t.AccountId = @AccountId

	UNION ALL

	SELECT
		'Credit Note Group' as [Entity Type]
		, cng.Id as [Entity ID]
		, cng.NetsuiteId as [Netsuite ID]
		, Concat('', InvoiceNumber) as [Details]
		, i.CustomerId as [Fusebill ID]
	FROM CreditNoteGroup cng
	INNER JOIN Invoice i ON i.Id = cng.InvoiceId
	WHERE i.AccountId = @AccountId

) result
order by [Fusebill ID] asc

GO

