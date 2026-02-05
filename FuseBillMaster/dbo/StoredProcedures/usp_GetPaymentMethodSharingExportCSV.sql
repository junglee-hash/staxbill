
CREATE PROCEDURE [dbo].[usp_GetPaymentMethodSharingExportCSV] (
	@AccountId bigint
)
AS 

SET TRANSACTION ISOLATION LEVEL SNAPSHOT
SET NOCOUNT, XACT_ABORT ON;

SELECT
	N'Stax Bill ID' as [StaxBillId]
	,N'Customer ID' as [CustomerReference]
	,N'Customer Company Name' as [CustomerCompanyName]
	,N'Customer First Name' as CustomerFirstName
	,N'Customer Last Name' as CustomerLastName
	,N'Payment Method ID' as PaymentMethodId
	,N'Payment Method First Name' as PaymentMethodFirstName
	,N'Payment Method Last Name' as PaymentMethodLastName
	,N'Payment Method Type' as PaymentMethodType
	,N'Payment Method Brand' as PaymentMethodBrand
	,N'Payment Method Last 4 Digits' as PaymentMethodLast4Digits
	,N'Current Payment Method Sharing Setting (On,Off,Default)' as CurrentPaymentMethodSharingSetting
	,N'Target Payment Method Sharing Setting (On,Off,Default)' as TargetPaymentMethodSharingSetting
UNION ALL

SELECT
	CAST(c.Id as VARCHAR) as [StaxBillId]
	,c.Reference as [CustomerReference]
	,c.CompanyName as [CustomerCompanyName]
	,c.FirstName as CustomerFirstName
	,c.LastName as CustomerLastName
	,CAST(pm.Id as VARCHAR) as [PaymentMethodId]
	,pm.FirstName as PaymentMethodFirstName
	,pm.LastName as PaymentMethodLastName
	,pt.Name as PaymentMethodType
	,pm.AccountType as PaymentMethodBrand
	,COALESCE(cc.MaskedCardNumber, ach.MaskedAccountNumber, '') as PaymentMethodLast4Digits
	,CASE WHEN pm.Sharing IS NULL THEN 'Default'
		WHEN pm.Sharing = 1 THEN 'On'
		ELSE 'Off' END as CurrentPaymentMethodSharingSetting
	,'' as TargetPaymentMethodSharingSetting
FROM Customer c 
INNER JOIN PaymentMethod pm ON c.Id = pm.CustomerId
	AND pm.PaymentMethodStatusId = 1
LEFT JOIN CreditCard cc ON cc.Id = pm.Id
LEFT JOIN AchCard ach ON ach.Id = pm.Id
INNER JOIN Lookup.PaymentMethodType pt ON pt.Id = pm.PaymentMethodTypeId
WHERE
	c.AccountId = @AccountId
	AND c.IsDeleted = 0

SET NOCOUNT, XACT_ABORT OFF;

GO

