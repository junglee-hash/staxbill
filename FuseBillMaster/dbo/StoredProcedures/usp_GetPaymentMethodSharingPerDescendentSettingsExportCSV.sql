
CREATE PROCEDURE [dbo].[usp_GetPaymentMethodSharingPerDescendentSettingsExportCSV] (
	@AccountId bigint
)
AS

SET TRANSACTION ISOLATION LEVEL SNAPSHOT
SET NOCOUNT, XACT_ABORT ON;

WITH RootGeneration AS(
--1st gen
SELECT
	 c.Id AS StaxBillId
	,c.Reference AS CustomerReference
	,c.CompanyName AS CustomerCompanyName
	,c.FirstName AS CustomerFirstName
	,c.LastName AS CustomerLastName
	,pm.Id AS PaymentMethodId
	,pmt.[Name] AS PaymentMethodType
	,pm.AccountType AS PaymentMethodBrand
	,cred.MaskedCardNumber
	,ach.MaskedAccountNumber
	,cc.Id AS DescendentStaxBillId
	,cc.Reference AS DescendentCustomerReference
	,cc.CompanyName AS DescendentCustomerCompanyName
	,cc.FirstName AS DescendentCustomerFirstName
	,cc.LastName AS DescendentCustomerLastName
	,pms.Sharing AS CurrentPaymentMethodSharingSetting

FROM Customer c
	INNER JOIN dbo.Customer cc ON cc.ParentId = c.Id AND cc.IsDeleted = 0
	INNER JOIN dbo.PaymentMethod pm ON pm.CustomerId = c.Id AND pm.PaymentMethodStatusId = 1
	INNER JOIN [Lookup].PaymentMethodType pmt ON pmt.Id = pm.PaymentMethodTypeId
	LEFT JOIN PaymentMethodSharing pms ON pms.CustomerId = cc.Id AND pms.PaymentMethodId = pm.id
	LEFT JOIN CreditCard cred ON cred.Id = pm.Id
	LEFT JOIN AchCard ach ON ach.Id = pm.Id

WHERE c.AccountId = @AccountId
	AND c.IsDeleted = 0
	AND c.ParentId IS NULL

UNION ALL

--2nd gen (p = Parent)
SELECT
	 p.Id AS StaxBillId
	,p.Reference AS CustomerReference
	,p.CompanyName AS CustomerCompanyName
	,p.FirstName AS CustomerFirstName
	,p.LastName AS CustomerLastName
	,pm.Id AS PaymentMethodId
	,pmt.[Name] AS PaymentMethodType
	,pm.AccountType AS PaymentMethodBrand
	,cred.MaskedCardNumber
	,ach.MaskedAccountNumber
	,cc.Id AS DescendentStaxBillId
	,cc.Reference AS DescendentCustomerReference
	,cc.CompanyName AS DescendentCustomerCompanyName
	,cc.FirstName AS DescendentCustomerFirstName
	,cc.LastName AS DescendentCustomerLastName
	,pms.Sharing AS CurrentPaymentMethodSharingSetting

FROM Customer c
	INNER JOIN Customer cc ON cc.ParentId = c.Id AND cc.IsDeleted = 0
	INNER JOIN Customer p ON p.Id = cc.ParentId AND p.IsDeleted = 0
	INNER JOIN PaymentMethod pm ON pm.CustomerId = p.Id AND pm.PaymentMethodStatusId = 1
	INNER JOIN [Lookup].PaymentMethodType pmt ON pmt.Id = pm.PaymentMethodTypeId
	LEFT JOIN PaymentMethodSharing pms ON pms.CustomerId = cc.Id AND pms.PaymentMethodId = pm.id
	LEFT JOIN CreditCard cred ON cred.Id = pm.Id
	LEFT JOIN AchCard ach ON ach.Id = pm.Id

WHERE cc.AccountId = @AccountId
	AND c.IsDeleted = 0
	AND c.ParentId IS NOT NULL

UNION ALL

--3rd gen (gp = Grandparent)
SELECT
	 gp.Id AS StaxBillId
	,gp.Reference AS CustomerReference
	,gp.CompanyName AS CustomerCompanyName
	,gp.FirstName AS CustomerFirstName
	,gp.LastName AS CustomerLastName
	,pm.Id AS PaymentMethodId
	,pmt.[Name] AS PaymentMethodType
	,pm.AccountType AS PaymentMethodBrand
	,cred.MaskedCardNumber
	,ach.MaskedAccountNumber
	,cc.Id AS DescendentStaxBillId
	,cc.Reference AS DescendentCustomerReference
	,cc.CompanyName AS DescendentCustomerCompanyName
	,cc.FirstName AS DescendentCustomerFirstName
	,cc.LastName AS DescendentCustomerLastName
	,pms.Sharing AS CurrentPaymentMethodSharingSetting

FROM Customer c
	INNER JOIN Customer cc ON cc.ParentId = c.Id AND cc.IsDeleted = 0
	INNER JOIN Customer p ON p.Id = cc.ParentId AND p.IsDeleted = 0
	INNER JOIN Customer gp ON gp.Id = p.ParentId AND gp.IsDeleted = 0
	INNER JOIN PaymentMethod pm ON pm.CustomerId = gp.Id AND PaymentMethodStatusId = 1
	INNER JOIN [Lookup].PaymentMethodType pmt ON pmt.Id = pm.PaymentMethodTypeId
	LEFT JOIN PaymentMethodSharing pms ON pms.CustomerId = cc.Id AND pms.PaymentMethodId = pm.id
	LEFT JOIN CreditCard cred ON cred.Id = pm.Id
	LEFT JOIN AchCard ach ON ach.Id = pm.Id

WHERE c.AccountId = @AccountId
	AND c.IsDeleted = 0
	AND c.ParentId IS NOT NULL

UNION ALL

--4th gen (ggp = Great Grandparent)
SELECT
	 ggp.Id AS StaxBillId
	,ggp.Reference AS CustomerReference
	,ggp.CompanyName AS CustomerCompanyName
	,ggp.FirstName AS CustomerFirstName
	,ggp.LastName AS CustomerLastName
	,pm.Id AS PaymentMethodId
	,pmt.[Name] AS PaymentMethodType
	,pm.AccountType AS PaymentMethodBrand
	,cred.MaskedCardNumber
	,ach.MaskedAccountNumber
	,cc.Id AS DescendentStaxBillId
	,cc.Reference AS DescendentCustomerReference
	,cc.CompanyName AS DescendentCustomerCompanyName
	,cc.FirstName AS DescendentCustomerFirstName
	,cc.LastName AS DescendentCustomerLastName
	,pms.Sharing AS CurrentPaymentMethodSharingSetting

FROM Customer c
	INNER JOIN Customer cc ON cc.ParentId = c.Id AND cc.IsDeleted = 0
	INNER JOIN Customer p ON p.Id = cc.ParentId AND p.IsDeleted = 0
	INNER JOIN Customer gp ON gp.Id = p.ParentId AND gp.IsDeleted = 0
	INNER JOIN Customer ggp ON ggp.Id = gp.ParentId AND ggp.IsDeleted = 0
	INNER JOIN PaymentMethod pm ON pm.CustomerId = ggp.Id AND PaymentMethodStatusId = 1
	INNER JOIN [Lookup].PaymentMethodType pmt ON pmt.Id = pm.PaymentMethodTypeId
	LEFT JOIN PaymentMethodSharing pms ON pms.CustomerId = cc.Id AND pms.PaymentMethodId = pm.id
	LEFT JOIN CreditCard cred ON cred.Id = pm.Id
	LEFT JOIN AchCard ach ON ach.Id = pm.Id

WHERE c.AccountId = @AccountId
	AND c.IsDeleted = 0
	AND c.ParentId IS NOT NULL
)

SELECT
	 N'Stax Bill ID' AS StaxBillId
	,N'Customer ID' AS CustomerReference
	,N'Customer Company Name' AS CustomerCompanyName
	,N'Customer First Name' AS CustomerFirstName
	,N'Customer Last Name' AS CustomerLastName
	,N'Payment Method ID' AS PaymentMethodId
	,N'Payment Method Type' AS PaymentMethodType
	,N'Payment Method Brand' AS PaymentMethodBrand
	,N'Payment Method Last 4 Digits' AS PaymentMethodLast4Digits
	,N'Descendent Stax Bill ID' AS DescendentStaxBillId
	,N'Descendent Customer ID' AS DescendentCustomerReference
	,N'Descendent Customer Company Name' AS DescendentCustomerCompanyName
	,N'Descendent Customer First Name' AS DescendentCustomerFirstName
	,N'Descendent Customer Last Name' AS DescendentCustomerLastName
	,N'Current Payment Method Sharing Setting (On,Off,Default)' AS CurrentPaymentMethodSharingSetting
	,N'Target Payment Method Sharing Setting (On,Off,Default)' AS TargetPaymentMethodSharingSetting

UNION ALL

SELECT
	 Cast(StaxBillId AS nvarchar)
	,CustomerReference
	,CustomerCompanyName
	,CustomerFirstName
	,CustomerLastName
	,CAST(PaymentMethodId AS nvarchar)
	,PaymentMethodType
	,PaymentMethodBrand
	,COALESCE(MaskedCardNumber, MaskedAccountNumber, '') AS PaymentMethodLast4Digits
	,CAST(DescendentStaxBillId AS nvarchar)
	,DescendentCustomerReference
	,DescendentCustomerCompanyName
	,DescendentCustomerFirstName
	,DescendentCustomerLastName
	,CASE WHEN CurrentPaymentMethodSharingSetting IS NULL THEN 'Default'
		WHEN CurrentPaymentMethodSharingSetting = 1 THEN 'On'
		ELSE 'Off' END AS CurrentPaymentMethodSharingSetting
	,'' as TargetPaymentMethodSharingSetting

FROM RootGeneration

GO

