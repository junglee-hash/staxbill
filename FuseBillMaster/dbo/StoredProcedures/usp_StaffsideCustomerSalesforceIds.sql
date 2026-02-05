Create Procedure [dbo].[usp_StaffsideCustomerSalesforceIds]
	@CustomerId bigint
AS

SELECT
	'Customer' as [Entity Type]
	,Id as [Entity Id]
	,SalesforceId as [Salesforce Id]
	,COALESCE(FirstName + ' ' + LastName, CompanyName,Reference) as [Details]
FROM Customer
WHERE Id = @CustomerId

UNION ALL

SELECT
	'Subscription' as [Entity Type]
	,Id as [Entity Id]
	,SalesforceId as [Salesforce Id]
	,PlanName as [Details]
FROM Subscription
WHERE CustomerId = @CustomerId

UNION ALL

SELECT
	'Subscription Product' as [Entity Type]
	,sp.Id as [Entity Id]
	,sp.SalesforceId as [Salesforce Id]
	,sp.PlanProductName as [Details]
FROM SubscriptionProduct sp
inner join Subscription s on s.Id = sp.SubscriptionId
WHERE s.CustomerId = @CustomerId

UNION ALL

SELECT
	'Subscription Product' as [Entity Type]
	,sp.Id as [Entity Id]
	,sp.SalesforceId as [Salesforce Id]
	,sp.PlanProductName as [Details]
FROM SubscriptionProduct sp
inner join Subscription s on s.Id = sp.SubscriptionId
WHERE s.CustomerId = @CustomerId

UNION ALL

SELECT
	'Purchase' as [Entity Type]
	,Id as [Entity Id]
	,SalesforceId as [Salesforce Id]
	,Name as [Details]
FROM Purchase
WHERE CustomerId = @CustomerId

UNION ALL

SELECT
	'Invoice' as [Entity Type]
	,Id as [Entity Id]
	,SalesforceId as [Salesforce Id]
	,Concat('', InvoiceNumber) as [Details]
FROM Invoice
WHERE CustomerId = @CustomerId

GO

