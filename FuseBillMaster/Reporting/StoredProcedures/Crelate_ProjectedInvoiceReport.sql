


CREATE     PROCEDURE [Reporting].[Crelate_ProjectedInvoiceReport]
--declare
	@AccountId bigint --= 3217131
AS

SET TRANSACTION ISOLATION LEVEL SNAPSHOT

DECLARE @AccountCustomers TABLE
(
  CustomerId bigint 
)

INSERT INTO @AccountCustomers
SELECT Id from Customer where Customer.AccountId = @AccountId


select 
	di.Total as [Projected invoice dollar amount]
	,c.Id as [Fusebill ID]
	,CONVERT(varchar,s.Id) as [Subscription ID]
	,bp.StartDate as [Projected invoice post date]
	,cu.IsoName as Currency
FROM
	DraftInvoice di
	inner join Customer c on c.Id = di.CustomerId
	inner join BillingPeriod bp on bp.Id = di.BillingPeriodId
	inner join BillingPeriodDefinition bpd on bp.BillingPeriodDefinitionId = bpd.Id
	inner join Subscription s on s.BillingPeriodDefinitionId = bpd.Id
	inner join Lookup.Currency cu ON cu.Id = c.CurrencyId
WHERE
	di.DraftInvoiceStatusId = 5 --projected
AND
	c.AccountId = @AccountId
and
	s.StatusId = 2


UNION ALL 

SELECT 
	pro.ProjectedTotal as [Projected invoice dollar amount]
	,pro.CustomerId as [Fusebill ID]
	,'' as [Subscription ID]
	,pro.EffectiveTimestamp as [Projected invoice post date]
	,cu.IsoName as Currency
FROM 
	ProjectedInvoice pro
inner join Customer c on c.Id = pro.CustomerId
inner join Lookup.Currency cu ON cu.Id = c.CurrencyId
WHERE
	pro.CustomerId in (SELECT CustomerId from @AccountCustomers)
	and 
	pro.ProjectedInvoiceId is null

order by [Fusebill ID],  [Projected invoice post date]

GO

