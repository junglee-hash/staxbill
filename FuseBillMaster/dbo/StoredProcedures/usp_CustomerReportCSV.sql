CREATE PROCEDURE [dbo].[usp_CustomerReportCSV]
	-- Add the parameters for the stored procedure here
	@AccountId bigint 
AS
BEGIN
	SET NOCOUNT ON;
declare @TimezoneId int

select @TimezoneId = TimezoneId
from AccountPreference where Id = @AccountId ;
	
	SELECT 
	c.Id as [Fusebill ID]
	,CASE WHEN str(c.ParentId) is null THEN '' ELSE str(c.ParentId) END as [Customer Parent ID]
	,CASE WHEN str(c.QuickBooksId) is null THEN '' ELSE str(c.QuickBooksId) END as [QuickBooks ID]
	,ISNULL(c.Reference, '') as [Customer ID]
	,ISNULL(c.CompanyName, '') as [Company Name]
	,ISNULL(title.Name,'') as [Title]
	,ISNULL(c.FirstName, '') as [First Name]
	,ISNULL(c.MiddleName, '') as [Middle Name]
	,ISNULL(c.LastName, '') as [Last Name]
	,ISNULL(c.Suffix, '') as [Suffix]
	,customerStatus.Name as [Status]
	,term.Name as [Terms]
	,CASE WHEN (cbs.AutoCollect = 1 OR
        (cbs.AutoCollect IS NULL AND abp.DefaultAutoCollect = 1)) AND pm.Id IS NULL THEN 'Missing' WHEN (cbs.AutoCollect = 1 OR
        (cbs.AutoCollect IS NULL AND abp.DefaultAutoCollect = 1)) AND pm.Id IS NOT NULL AND pm.PaymentMethodTypeId = 3 THEN 'Credit Card' 
		WHEN (cbs.AutoCollect = 1 OR (cbs.AutoCollect IS NULL AND abp.DefaultAutoCollect = 1)) AND pm.Id IS NOT NULL AND pm.PaymentMethodTypeId = 5 THEN 'ACH' 
		WHEN (cbs.AutoCollect = 1 OR (cbs.AutoCollect IS NULL AND abp.DefaultAutoCollect = 1)) AND pm.Id IS NOT NULL AND pm.PaymentMethodTypeId = 6 THEN 'Paypal' 
		WHEN (cbs.AutoCollect = 0 OR (cbs.AutoCollect IS NULL AND abp.DefaultAutoCollect = 0)) AND pm.Id IS NOT NULL THEN 'AR - Pay method on file' 
		WHEN pm.Id IS NULL THEN 'AR' END AS [Payment Method]
	,customerAccountStatus.Name as [Accounting Status]
	,c.ArBalance as [AR Balance]
	,convert(datetime,dbo.fn_GetTimezoneTime(c.EffectiveTimestamp, @TimezoneId )) as [Created] 
	,convert(datetime,dbo.fn_getTimezoneTime(c.NextBillingDate, @TimezoneId)) as [Next Billing Date]
	,CASE WHEN cbs.AutoPostDraftInvoice IS NULL THEN abp.AutoPostDraftInvoice ELSE cbs.AutoPostDraftInvoice END as [Auto Post Draft Invoice]
	,CASE WHEN cbs.AutoCollect IS NULL THEN abp.DefaultAutoCollect ELSE cbs.AutoCollect END AS [Auto Collect]
	,currency.IsoName as [Currency]
	,CASE WHEN abp.AutoSuspendEnabled = 1 AND c.AccountStatusId = 2 AND c.StatusId = 2 THEN str( (isnull(cbs.CustomerGracePeriod,   isnull(abp.AccountGracePeriod, 0)) + isnull(cbs.GracePeriodExtension, 0) - (DATEDIFF(d, cj.EffectiveTimestamp, GETUTCDATE())))) ELSE '' END AS [Days Until Suspension]
	,ISNULL(c.PrimaryEmail, '') as [Primary Email]
	,ISNULL(c.PrimaryPhone, '') as [Primary Phone]
	,ISNULL(c.SecondaryEmail, '') as [Secondary Email]
	,ISNULL(c.SecondaryPhone, '') as [Seconfary Phone]
	,ISNULL(cr.Reference1, '') as [Reference 1]
	,ISNULL(cr.Reference2, '') as [Reference 2]
	,ISNULL(cr.Reference3, '') as [Reference 3]
	,ISNULL(ca.AdContent, '') as [Ad Content]
	,ISNULL(ca.Campaign, '') as [Campaign]
	,ISNULL(ca.Keyword, '') as [Keyword]
	,ISNULL(ca.LandingPage, '') as [Landing Page]
	,ISNULL(ca.Medium, '') as [Medium]
	,ISNULL(ca.[Source], '') as [Source]
	,CASE WHEN afc.MrrDisplayTypeId = 1 THEN c.MonthlyRecurringRevenue ELSE c.CurrentMrr END as [Monthly Recurring Revenue]
	,CASE WHEN afc.MrrDisplayTypeId = 1 THEN c.NetMRR ELSE c.CurrentNetMrr END AS [Net MRR]
	,ISNULL(c.SalesforceId, '') as [Salesforce Id]
	,ISNULL(c.NetsuiteId, '') as [Netsuite Id]
	,ISNULL(stc1.Code, '') as [SalesTrackingCode1Code]
	,ISNULL(stc1.Name, '') as [SalesTrackingCode1Name]
	,ISNULL(stc2.Code, '') as [SalesTrackingCode2Code]
	,ISNULL(stc2.Name, '') as [SalesTrackingCode2Name]
	,ISNULL(stc3.Code, '') as [SalesTrackingCode3Code]
	,ISNULL(stc3.Name, '') as [SalesTrackingCode3Name]
	,ISNULL(stc4.Code, '') as [SalesTrackingCode4Code]
	,ISNULL(stc4.Name, '') as [SalesTrackingCode4Name]
	,ISNULL(stc5.Code, '') as [SalesTrackingCode5Code]
	,ISNULL(stc5.Name, '') as [SalesTrackingCode5Name]
	,cap.ContactName as [Contact Name]
	,ISNULL(cap.ShippingInstructions, '') as [Shipping Instructions]
	,cap.UseBillingAddressAsShippingAddress as [Use Billing Address As Shipping Address]
	,ISNULL(ba.CompanyName, '') as [Billing Company Name]
	,ISNULL(ba.Line1, '') as [Billing Line 1]
	,ISNULL(ba.Line2, '') as [Billing Line 2]
	,ISNULL(ba.City, '') as [Billing City]
	,ISNULL(ba.PostalZip, '') as [Billing Postal Zip]
	,ISNULL(billingCountry.Name, '') as [Billing Country]
	,ISNULL(ba.County, '') as [Billing County]
	,ISNULL(billingState.Name, '') as [Billing State]
	,ISNULL(sa.CompanyName, '') as [Shipping Company Name]
	,ISNULL(sa.Line1, '') as [Shipping Line 1]
	,ISNULL(sa.Line2, '') as [Shipping Line 2]
	,ISNULL(sa.City, '') as [Shipping City]
	,ISNULL(sa.PostalZip, '') as [Shipping Postal Zip]
	,ISNULL(shippingCountry.Name, '') as [Shipping Country]
	,ISNULL(shippingState.Name, '') as [Shipping State]
	,CASE WHEN pm.CustomerId <> c.Id THEN CAST(1 as bit) ELSE CAST(0 as bit) END AS [Is Parent Payment Method]

	FROM
	Customer c
	INNER JOIN Lookup.CustomerStatus customerStatus ON c.StatusId = customerStatus.Id AND c.AccountId = @AccountId
	INNER JOIN Lookup.CustomerAccountStatus customerAccountStatus ON c.AccountStatusId = CustomerAccountStatus.Id 
	LEFT JOIN Lookup.Title title on c.TitleId = title.Id
	INNER Join Lookup.Currency currency on c.CurrencyId = currency.Id
	INNER JOIN dbo.CustomerAccountStatusJournal AS cj ON c.Id = cj.CustomerId AND cj.IsActive = 1
	INNER JOIN AccountFeatureConfiguration afc on afc.Id = c.AccountId	

	-- ADDRESS JOINS
	INNER JOIN CustomerAddressPreference cap on cap.Id = c.Id
	LEFT JOIN [Address] ba on ba.CustomerAddressPreferenceId = cap.Id and ba.AddressTypeId = 1 -- billing
	LEFT JOIN Lookup.Country billingCountry ON billingCountry.Id = ba.CountryId
	LEFT JOIN Lookup.[State] billingState ON billingState.Id = ba.StateId
	LEFT JOIN [Address] sa on sa.CustomerAddressPreferenceId = cap.Id and sa.AddressTypeId = 2 -- shipping
	LEFT JOIN Lookup.Country shippingCountry ON shippingCountry.Id = sa.CountryId
	LEFT JOIN Lookup.[State] shippingState ON shippingState.Id = sa.StateId
	
	--CUSTOMER REFERENCE JOINS
	INNER JOIN CustomerReference cr on cr.Id = c.Id
	LEFT JOIN SalesTrackingCode stc1 on cr.SalesTrackingCode1Id = stc1.Id
	LEFT JOIN SalesTrackingCode stc2 on cr.SalesTrackingCode2Id = stc2.Id
	LEFT JOIN SalesTrackingCode stc3 on cr.SalesTrackingCode3Id = stc3.Id
	LEFT JOIN SalesTrackingCode stc4 on cr.SalesTrackingCode4Id = stc4.Id
	LEFT JOIN SalesTrackingCode stc5 on cr.SalesTrackingCode5Id = stc5.Id

	INNER JOIN CustomerAcquisition ca on ca.Id = c.Id	
	
	-- BILLING JOINS
	INNER JOIN CustomerBillingSetting cbs on cbs.Id = c.Id
	INNER JOIN Lookup.Term term ON cbs.TermId = term.Id
	INNER JOIN AccountBillingPreference abp on abp.Id = c.AccountId
	LEFT JOIN dbo.PaymentMethod AS pm ON pm.Id = cbs.DefaultPaymentMethodId 
	
	WHERE c.IsDeleted = 0

END

GO

