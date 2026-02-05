
CREATE     PROCEDURE [Reporting].[RadiusNetworks_ProjectedInvoiceReport]
	@AccountId bigint
AS

SET TRANSACTION ISOLATION LEVEL SNAPSHOT


select 
	CONVERT(varchar,di.Id) as [Projected Invoice ID]
	,di.Total as [Projected invoice dollar amount]
	,c.Id as [Stax Bill ID]
	,CONVERT(varchar,s.Id) as [Subscription ID]
	,di.EffectiveTimestamp as [Projected invoice post date]
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



UNION ALL 

SELECT 
	'' as [Projected Invoice ID]
	,pro.ProjectedTotal as [Projected invoice dollar amount]
	,pro.CustomerId as [Stax Bill ID]
	,'' as [Subscription ID]
	,pro.EffectiveTimestamp as [Projected invoice post date]
	,cu.IsoName as Currency
FROM 
	ProjectedInvoice pro
inner join Customer c on c.Id = pro.CustomerId
inner join Lookup.Currency cu ON cu.Id = c.CurrencyId
WHERE
	c.AccountId = @AccountId
	and 
	pro.ProjectedInvoiceId is null

order by [Stax Bill ID],  [Projected invoice post date]

GO

