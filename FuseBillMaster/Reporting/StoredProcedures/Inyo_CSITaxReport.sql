
Create PROCEDURE [Reporting].[Inyo_CSITaxReport]
		@AccountId bigint-- = 37163--= 1777-- = 2941619--1730
AS
BEGIN

set nocount on
set transaction isolation level snapshot

DECLARE @TimezoneId int

SELECT @TimezoneId = TimezoneId
	FROM AccountPreference
	WHERE Id = @AccountId
;with prodCFs as (
SELECT pcf.SubscriptionProductId --pcf.ProductId
		,MAX(case when cf.[Key] = 'SorP' then coalesce(pcf.StringValue, cast(pcf.NumericValue as varchar), cast(pcf.DateValue as varchar), '') else '' END) as [CF_SorP]
		,MAX(case when cf.[Key] = 'Product' then coalesce(pcf.StringValue, cast(pcf.NumericValue as varchar), cast(pcf.DateValue as varchar), '') else '' end) as [CF_Product]
		,MAX(case when cf.[Key] = 'Service' then coalesce(pcf.StringValue, cast(pcf.NumericValue as varchar), cast(pcf.DateValue as varchar), '') else '' end) as [CF_Service]
		,MAX(case when cf.[Key] = 'TaxablePercentage' then coalesce(pcf.StringValue, cast(pcf.NumericValue as varchar), cast(pcf.DateValue as varchar), '') else '' end) as [CF_TaxablePercentage]
		,MAX(case when cf.[Key] = 'LocationA' then coalesce(pcf.StringValue, cast(pcf.NumericValue as varchar), cast(pcf.DateValue as varchar), '') else '' end) as [CF_LocationA]
		,MAX(case when cf.[Key] = 'LocationZ' then coalesce(pcf.StringValue, cast(pcf.NumericValue as varchar), cast(pcf.DateValue as varchar), '') else '' end) as [CF_LocationZ]
		FROM [dbo].SubscriptionProductCustomField pcf --[dbo].ProductCustomField pcf
		inner join [dbo].CustomField cf on cf.id = pcf.CustomFieldId
		WHERE cf.AccountId = @AccountId
		and cf.[Key] in ('SorP', 'Product', 'Service', 'TaxablePercentage','LocationA','LocationZ')
		and coalesce(pcf.StringValue, cast(pcf.NumericValue as varchar), cast(pcf.DateValue as varchar)) is not Null
		group by SubscriptionProductId--pcf.ProductId
)
--Select * from prodCFs

Select coalesce(pcfs.CF_SorP, '') as [ ] --No column heading values should e either S or P taken from product level custom field name "S or P"
	,Concat(c.id, '-', pcfs.SubscriptionProductId) as [Customer Account ID]
    ,isnull(cf.Reference1, '') as [Customer Type]
    ,coalesce(NULLIF(pcfs.CF_LocationA, ' '), a.PostalZip) as [Service Location Zip Code/Private Line Zip A]
    ,coalesce(pcfs.CF_LocationZ, '') as [Private Line ZIP Z]
    ,'' as [Call Originating NPA/NXX] --blank
    ,'' as [Call Terminating NPA/NXX] --blank
    ,'' as [Call Billing NPA/NXX] --blank
    ,REPLACE(convert(date,dbo.fn_GetTimezoneTime(c.[NextBillingDate], @TimezoneId),112),'-','')  as [Invoice Date]
    ,'' as [Invoice Number] --blank
    ,coalesce(pcfs.CF_Product, '') as [Product]	-- Product Level Custom Field - 'Product'
    ,coalesce(pcfs.CF_Service, '') as [Service]	--Product Level Custom Field - 'Service'
    --,dc.Amount as [RevenueNotax]	--Product Invoice Amount
	,case when (pcfs.CF_TaxablePercentage is Null or pcfs.CF_TaxablePercentage <> '') then round((dc.Amount + (dc.Amount * (convert(money, pcfs.CF_TaxablePercentage)/100))),2) else dc.Amount end as [Revenue] --Product Invoice Amount
    ,'' as [Line Count] --blank
    ,'' as [Call Minutes] --blank
    ,case when cbs.TaxExempt = 1 then 'Y' else 'N' end as [Exempt]	--Customer Tax Exempt Status (Y or N)
    ,'' as [Exempt List] --blank
    ,case when stc1.Code = 'Y' then 'Y' else 'N' end as [Percent Tax Override Flag] --Sales Tracking Code 1 - If Y, then Y if Blank then N
    ,'' as [Percent Tax Override] --blank

 FROM [dbo].[Customer] c 
 inner join [dbo].[ProjectedInvoice] p1 on c.id = p1.customerId
 inner join [dbo].draftinvoice d on d.id = p1.projectedInvoiceid
 inner join [dbo].[DraftCharge] dc on dc.DraftInvoiceId = p1.[ProjectedInvoiceId]
 inner join [dbo].[DraftSubscriptionProductCharge] dspc on dspc.Id = dc.Id
 inner join prodCFs pcfs on pcfs.SubscriptionProductId = dspc.SubscriptionProductId and pcfs.[CF_Product] <> ''--pcfs.ProductId = dc.ProductId
 inner join [dbo].[CustomerReference] cf on cf.id = c.id
 left join [dbo].[SalesTrackingCode] stc1 on stc1.id = cf.SalesTrackingCode1Id
 inner join [dbo].CustomerBillingSetting cbs on cbs.id = c.Id
 left join [dbo].[Address] a on a.[CustomerAddressPreferenceId] = c.id
 where c.accountid = @AccountId 
END

GO

