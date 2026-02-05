
CREATE   PROCEDURE [dbo].[Staffside_PaymentMethodDetails]
	@AccountId BIGINT
AS

SET TRANSACTION ISOLATION LEVEL SNAPSHOT
Select 
	pm.id as paymentmethodid, 
	c.id as customerid, 
	pm.FirstName as PaymentMethodFirstName, 
	pm.LastName as PaymentMethodLastName,
	pm.StoredInStax,
	pm.StoredInFusebillVault,
	case 
		When achc.Id is not null Then achc.MaskedAccountNumber
		When cc.Id is not null Then cc.MaskedCardNumber
		Else ''
	End as LastFour,
	Case
		When cbs.DefaultPaymentMethodId = pm.Id Then '1'
		Else '0'
	End as IsDefault,
	cc.ExpirationMonth as 'Expiry Month',
	cc.ExpirationYear as 'Expiry Year',
--	cast(cast(pm.CreatedTimestamp as datetime) + 2e as float) 
	pm.CreatedTimestamp as 'Created Timestamp', 
--	cast(cast(c.nextbillingDate as datetime) + 2e as float) 
	c.nextbillingDate as 'Next Billing Date',
	cs.Name as CustomerStatus,
	cas.Name as CustomerAccountStatus,
	c.FirstName as CustomerFirstName,
	c.LastName as CustomerLastName,
	c.PrimaryEmail as CustomerEmail,
	pms.[Name] as 'Payment Method Status',
	CASE WHEN
		IsNull(Address1, '') = ''
		OR IsNull(City, '') = ''
		OR IsNull(PostalZip, '') = ''
		OR IsNull(CountryId, '') = ''
		THEN 'FALSE'
		ELSE 'TRUE'
		END AS [Payment Method Address Filled out]

from PaymentMethod pm
inner join Customer c on c.Id = pm.CustomerId
inner join Lookup.PaymentMethodStatus pms on pms.Id = pm.PaymentMethodStatusId
inner join CustomerBillingSetting cbs on cbs.Id = c.Id
inner join lookup.CustomerStatus cs on cs.Id = c.StatusId
inner join lookup.CustomerAccountStatus cas on cas.Id = c.AccountStatusId
left join CreditCard cc on cc.id = pm.Id
left join AchCard achc on achc.id = pm.Id
where c.AccountId = @AccountId 
and (pm.PaymentMethodStatusId = 1 or pm.PaymentMethodStatusId = 3)
order by pm.id desc

GO

