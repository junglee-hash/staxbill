CREATE FUNCTION [dbo].[CustomerExportCSVCustomerAddress]
(	
	@FusebillId as bigint
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT 
	ISNULL(ba.CompanyName, '') as [Billing Company Name]
	,ISNULL(ba.Line1, '') as [Billing Line 1]
	,ISNULL(ba.Line2, '') as [Billing Line 2]
	,ISNULL(ba.City, '') as [Billing City]
	,ISNULL(billingCountry.Name, '') as [Billing Country]
	,ISNULL(ba.County, '') as [Billing County]
	,ISNULL(billingState.Name, '') as [Billing State]
	,ISNULL(ba.PostalZip, '') as [Billing Postal Zip]
	,cap.UseBillingAddressAsShippingAddress as [Use Billing Address As Shipping Address]
	,cap.ContactName as [Contact Name]
	,ISNULL(cap.ShippingInstructions, '') as [Shipping Instructions]
	,ISNULL(sa.CompanyName, '') as [Shipping Company Name]
	,ISNULL(sa.Line1, '') as [Shipping Line 1]
	,ISNULL(sa.Line2, '') as [Shipping Line 2]
	,ISNULL(sa.City, '') as [Shipping City]
	,ISNULL(shippingCountry.Name, '') as [Shipping Country]
	,ISNULL(shippingState.Name, '') as [Shipping State]
	,ISNULL(sa.PostalZip, '') as [Shipping Postal Zip]


	FROM
	CustomerAddressPreference cap
	LEFT JOIN [Address] ba on ba.CustomerAddressPreferenceId = cap.Id and ba.AddressTypeId = 1 -- billing
	LEFT JOIN Lookup.Country billingCountry ON billingCountry.Id = ba.CountryId
	LEFT JOIN Lookup.[State] billingState ON billingState.Id = ba.StateId
	LEFT JOIN [Address] sa on sa.CustomerAddressPreferenceId = cap.Id and sa.AddressTypeId = 2 -- shipping
	LEFT JOIN Lookup.Country shippingCountry ON shippingCountry.Id = sa.CountryId
	LEFT JOIN Lookup.[State] shippingState ON shippingState.Id = sa.StateId

	WHERE cap.Id = @FusebillId
)

GO

