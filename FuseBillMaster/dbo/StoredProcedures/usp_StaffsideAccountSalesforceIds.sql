Create Procedure [dbo].[usp_StaffsideAccountSalesforceIds]
	@AccountId bigint
AS

--Declare
--	@AccountId bigint
--Set @AccountId = 20

Select 
	[Fusebill Id]
	,[Entity Type]
	,[Entity Id]
	,[Salesforce Id]
	,[Details]
from(
	SELECT
		'Customer' as [Entity Type]
		,Id as [Entity Id]
		,SalesforceId as [Salesforce Id]
		,COALESCE(FirstName + ' ' + LastName, CompanyName,Reference) as [Details]
		,Id as [Fusebill Id]
	FROM Customer
	WHERE AccountId = @AccountId

	UNION ALL

	SELECT
		'Subscription' as [Entity Type]
		,s.Id as [Entity Id]
		,s.SalesforceId as [Salesforce Id]
		,s.PlanName as [Details]
		,CustomerId as [Fusebill Id]
	FROM Subscription s
	inner join Customer c on c.Id = s.CustomerId
	WHERE  c.AccountId = @AccountId

	UNION ALL

	SELECT
		'Subscription Product' as [Entity Type]
		,sp.Id as [Entity Id]
		,sp.SalesforceId as [Salesforce Id]
		,sp.PlanProductName as [Details]
		,CustomerId as [Fusebill Id]
	FROM SubscriptionProduct sp
	inner join Subscription s on s.Id = sp.SubscriptionId
	inner join Customer c on c.Id = s.CustomerId
	WHERE  c.AccountId = @AccountId

	UNION ALL

	SELECT
		'Purchase' as [Entity Type]
		,p.Id as [Entity Id]
		,p.SalesforceId as [Salesforce Id]
		,p.Name as [Details]
		,CustomerId as [Fusebill Id]
	FROM Purchase p 
	inner join Customer c on c.Id = p.CustomerId
	WHERE c.AccountId = @AccountId

	UNION ALL

	SELECT
		'Invoice' as [Entity Type]
		,Id as [Entity Id]
		,SalesforceId as [Salesforce Id]
		,Concat('', InvoiceNumber) as [Details]
		,CustomerId as [Fusebill Id]
	FROM Invoice
	WHERE AccountId = @AccountId
) result
order by [Fusebill Id] asc

GO

