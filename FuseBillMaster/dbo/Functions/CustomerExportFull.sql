CREATE FUNCTION [dbo].[CustomerExportFull]
(
	@AccountId BIGINT
)
RETURNS TABLE 
AS
RETURN 
(
	WITH ParentCustomers AS
	(
		SELECT
			DISTINCT ParentId
		FROM Customer 
		WHERE AccountId = @AccountId
			AND ParentId IS NOT NULL
	)

	SELECT

		/** Basic Start **/
		c.Id as [Fusebill ID]
		,isnull(c.Reference,'') as [Customer ID]
		,isnull(c.FirstName,'') as  [Customer First Name]
		,isnull(c.LastName,'') as [Customer Last Name]
		,isnull(c.CompanyName,'') as [Customer Company Name]
		,customerStatus.Name as [Current Status]
		,isnull(CONVERT(varchar,c.ParentId), '') as [Customer Parent ID] 
		,CASE WHEN str(c.QuickBooksId) is null THEN '' ELSE str(c.QuickBooksId) END as [QuickBooks ID]
		,ISNULL(qblt.Name, '') as [QuickBooks Latch Type]
		,ISNULL(c.SalesforceId, '') as [Salesforce Id]
		,ISNULL(sfat.Name, '') as [Salesforce Account Type]
		,ISNULL(sfss.Name, '') as [Salesforce Synch Status]
		,ISNULL(c.NetsuiteId, '') as [Netsuite Id] 
		,ISNULL(nsss.Name, '') as [Netsuite Synch Status]
		/** Basic End **/

		/** Customer Contact **/
		,ISNULL(title.Name,'') as [Title]
		,ISNULL(c.MiddleName, '') as [Middle Name]
		,ISNULL(c.Suffix, '') as [Suffix]
		,convert(datetime,dbo.fn_GetTimezoneTime(c.ModifiedTimestamp, ap.TimezoneId)) as [Modified Timestamp]
		,ISNULL(CONVERT(varchar(20),convert(datetime,dbo.fn_GetTimezoneTime(c.ActivationTimestamp, ap.TimezoneId)), 120), '') as [Activation Timestamp]
		,ISNULL(CONVERT(varchar(20),convert(datetime,dbo.fn_GetTimezoneTime(c.CancellationTimestamp, ap.TimezoneId)), 120), '') as [Cancellation Timestamp]
		,ISNULL(cred.Username, '') as [Portal User Name]
		,CASE WHEN(cred.Password IS NULL) THEN 'false' ELSE 'true' END as [Portal Password Set]
		,customerAccountStatus.Name as [Accounting Status]
		,c.ArBalance as [AR Balance]
		,currency.IsoName as [Currency]
		,convert(datetime,dbo.fn_GetTimezoneTime(c.EffectiveTimestamp, ap.TimezoneId )) as [Created Timestamp] 
		,ISNULL(c.PrimaryEmail, '') as [Primary Email]
		,ISNULL(c.PrimaryPhone, '') as [Primary Phone]
		,ISNULL(c.SecondaryEmail, '') as [Secondary Email]
		,ISNULL(c.SecondaryPhone, '') as [Secondary Phone]
		,CASE WHEN afc.MrrDisplayTypeId = 1 THEN c.MonthlyRecurringRevenue ELSE c.CurrentMrr END as [Monthly Recurring Revenue]
		,CASE WHEN afc.MrrDisplayTypeId = 1 THEN c.NetMRR ELSE c.CurrentNetMrr END AS [Net MRR]
		,CASE WHEN parents.ParentId IS NOT NULL THEN 'true' ELSE 'false' END AS [Customer Is A Parent]
		/** Customer Contact End **/

		/** Billing Start **/
		,ISNULL(cbs.StandingPo, '') as [Standing PO]
		,ISNULL(cbs.AcquisitionCost, '') as [Acquisition Cost]
		,CASE WHEN (cbs.ShowZeroDollarCharges = 1) THEN 'true' ELSE 'false' END as [Show Zero Dollar Charges]
		,CASE WHEN (cbs.TaxExempt = 1) THEN 'true' ELSE 'false' END as [Tax Exempt]
		,ISNULL(cbs.TaxExemptCode, '') as [Tax Exempt Code]
		,ISNULL(cbs.AvalaraUsageType, '' ) as [Avalara Usage Type]
		,ISNULL(cbs.VATIdentificationNumber, '' ) as [VAT Identification Number]
		,CASE WHEN cbs.UseCustomerBillingAddress = 1 THEN 'true' WHEN aap.UseCustomerBillingAddress = 1 THEN 'true' ELSE 'false' END as [Use Billing Address for Tax]
		,CASE WHEN cbs.AutoCollect IS NULL THEN abp.DefaultAutoCollect ELSE cbs.AutoCollect END AS [Auto Collect] -- should change to display true or false
		,ISNULL(rt.Name, '') as [Recharge Type]
		,ISNULL(CONVERT(varchar, cbs.RechargeThresholdAmount), '' ) as [Recharge Threshold Amount]
		,ISNULL(CONVERT(varchar, cbs.RechargeTargetAMount), '' ) as [Recharge Target Amount]
		,CASE WHEN cbs.StatusOnThreshold = 1 THEN 'true' ELSE 'false'  END as [Status On Threshold]
		,term.Name as [Terms]
		,CASE WHEN pm.CustomerId <> c.Id THEN 'true' ELSE 'false' END AS [Is Parent Payment Method]
		,CASE WHEN (cbs.AutoCollect = 1 OR
			(cbs.AutoCollect IS NULL AND abp.DefaultAutoCollect = 1)) AND pm.Id IS NULL THEN 'Missing' WHEN (cbs.AutoCollect = 1 OR
			(cbs.AutoCollect IS NULL AND abp.DefaultAutoCollect = 1)) AND pm.Id IS NOT NULL AND pm.PaymentMethodTypeId = 3 THEN 'Credit Card' 
			WHEN (cbs.AutoCollect = 1 OR (cbs.AutoCollect IS NULL AND abp.DefaultAutoCollect = 1)) AND pm.Id IS NOT NULL AND pm.PaymentMethodTypeId = 5 THEN 'ACH' 
			WHEN (cbs.AutoCollect = 1 OR (cbs.AutoCollect IS NULL AND abp.DefaultAutoCollect = 1)) AND pm.Id IS NOT NULL AND pm.PaymentMethodTypeId = 6 THEN 'Paypal' 
			WHEN (cbs.AutoCollect = 0 OR (cbs.AutoCollect IS NULL AND abp.DefaultAutoCollect = 0)) AND pm.Id IS NOT NULL THEN 'AR - Pay method on file' 
			WHEN pm.Id IS NULL THEN 'AR' END AS [Payment Method]
		,CASE WHEN ( pm.Id IS NOT NULL AND pm.PaymentMethodTypeId = 3) 
			THEN ISNULL(CONVERT(varchar, cc.ExpirationMonth), '') ELSE '' END as [Credit Card Expiry Month]
		,CASE WHEN ( pm.Id IS NOT NULL AND pm.PaymentMethodTypeId = 3) 
			THEN ISNULL(CONVERT(varchar, cc.ExpirationYear), '') ELSE '' END as [Credit Card Expiry Year]
		,ISNULL(CONVERT(varchar(20),convert(datetime,dbo.fn_GetTimezoneTime(c.NextBillingDate, ap.TimezoneId)), 120), '') as [Next Billing Date]
 		,CASE WHEN cbs.AutoPostDraftInvoice IS NULL THEN CASE WHEN abp.AutoPostDraftInvoice = 1 THEN 'true' ELSE 'false' END ELSE CASE WHEN cbs.AutoPostDraftInvoice = 1 THEN 'true' ELSE 'false' END END as [Auto Post Draft Invoice]
       

		,CASE WHEN abp.AutoSuspendEnabled = 1 AND c.AccountStatusId = 2 AND c.StatusId = 2 THEN str( (isnull(cbs.CustomerGracePeriod,   isnull(abp.AccountGracePeriod, 0)) + isnull(cbs.GracePeriodExtension, 0) - (DATEDIFF(d, cj.EffectiveTimestamp, GETUTCDATE())))) ELSE '' END AS [Days Until Suspension]

		,CASE WHEN cbpcm.Id IS NULL THEN ISNULL(abptm.Name, '') ELSE ISNULL(bptm.Name, '') END as [Monthly Billing Period Configuration Type]
		,CASE WHEN cbpcm.Id IS NULL THEN ISNULL(abprm.Name, '') ELSE ISNULL(bprm.Name, '') END as [Monthly Billing Period Configuration Rule]
		,CASE WHEN cbpcm.Id IS NULL THEN ISNULL(CONVERT(varchar, abpcm.Day), '') ELSE ISNULL(CONVERT(varchar, cbpcm.Day), '') END as [Monthly Billing Period Configuration Day]
		,CASE WHEN cbpcm.Id IS NULL THEN ISNULL(CONVERT(varchar, abpcm.Month), '') ELSE ISNULL(CONVERT(varchar, cbpcm.Month), '') END as [Monthly Billing Period Configuration Month]
		,CASE WHEN cbpcy.Id IS NULL THEN ISNULL(abpty.Name, '') ELSE ISNULL(bpty.Name, '') END as [Yearly Billing Period Configuration Type]
		,CASE WHEN cbpcy.Id IS NULL THEN ISNULL(abpry.Name, '') ELSE ISNULL(bpry.Name, '') END as [Yearly Billing Period Configuration Rule]
		,CASE WHEN cbpcy.Id IS NULL THEN ISNULL(CONVERT(varchar, abpcy.Day), '') ELSE  ISNULL(CONVERT(varchar, cbpcy.Day), '') END as [Yearly Billing Period Configuration Day]
		,CASE WHEN cbpcy.Id IS NULL THEN ISNULL(CONVERT(varchar, abpcy.Month), '') ELSE ISNULL(CONVERT(varchar, cbpcy.Month), '') END as [Yearly Billing Period Configuration Month]
		,CASE WHEN cbss.ShowTrackedItemName = 1 THEN 'true' ELSE 'false' END as [Billing Statement Show Tracked Item Name]
		,CASE WHEN cbss.ShowTrackedItemReference = 1 THEN 'true' ELSE 'false' END as [Billing Statement Show Tracked Item Reference]
		,CASE WHEN cbss.ShowTrackedItemDescription = 1 THEN 'true' ELSE 'false' END as [Billing Statement Show Tracked Item Description]
		,CASE WHEN cbss.ShowTrackedItemCreatedDate = 1 THEN 'true' ELSE 'false' END as [Billing Statement Show Tracked Item Created Date]

		,CASE WHEN (cis.RollUpTaxes = 1) THEN 'true' ELSE 'false' END as [Roll Up Taxes]
		,CASE WHEN (cis.RollUpDiscounts = 1) THEN 'true' ELSE 'false' END as [Roll Up Discounts]
		,CASE WHEN (cis.ShowTrackedItemDescription = 1) or (cis.ShowTrackedItemName = 1) or (cis.ShowTrackedItemReference = 1) THEN 'true' ELSE 'false' END as [Show Tracked Items on Invoice]
		,ISNULL(tidf.Name, '') as [Tracked Item Display Type] 
		,CASE WHEN (cis.ShowTrackedItemName  = 1) THEN 'true' ELSE 'false' END as [Invoice Show Tracked Item Name]
		,CASE WHEN (cis.ShowTrackedItemReference  = 1) THEN 'true' ELSE 'false' END as [Invoice Show Tracked Item Reference]
		,CASE WHEN (cis.ShowTrackedItemDescription  = 1) THEN 'true' ELSE 'false' END as [Invoice Show Tracked Item Description]
		,CASE WHEN (cis.ShowTrackedItemCreatedDate  = 1) THEN 'true' ELSE 'false' END as [Invoice Show Tracked Item Created Date]
		,ISNULL(CONVERT(varchar,CONVERT(Decimal(14,2), csd.OpeningBalance)), '' ) as [Customer Opening Balance]
		/** Billing End **/

		/** Tracking Start **/
		,ISNULL(cr.Reference1, '') as [Ref1]
		,ISNULL(cr.Reference2, '') as [Ref2]
		,ISNULL(cr.Reference3, '') as [Ref3]
		,ISNULL(ca.AdContent, '') as [Ad Content]
		,ISNULL(ca.Campaign, '') as [Campaign]
		,ISNULL(ca.Keyword, '') as [Keyword]
		,ISNULL(ca.LandingPage, '') as [Landing Page]
		,ISNULL(ca.Medium, '') as [Medium]
		,ISNULL(ca.[Source], '') as [Source]
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

		/** Tracking End **/

		/** Address Start **/
		,ISNULL(ba.CompanyName, '') as [Billing Company Name]
		,ISNULL(ba.Line1, '') as [Billing Line 1]
		,ISNULL(ba.Line2, '') as [Billing Line 2]
		,ISNULL(ba.City, '') as [Billing City]
		,ISNULL(ba.Country, '') as [Billing Country]
		,ISNULL(ba.County, '') as [Billing County]
		,ISNULL(ba.State, '') as [Billing State]
		,ISNULL(ba.PostalZip, '') as [Billing Postal Zip]
		,cap.UseBillingAddressAsShippingAddress as [Use Billing Address As Shipping Address]
		,cap.ContactName as [Contact Name]
		,ISNULL(cap.ShippingInstructions, '') as [Shipping Instructions]
		,ISNULL(sa.CompanyName, '') as [Shipping Company Name]
		,ISNULL(sa.Line1, '') as [Shipping Line 1]
		,ISNULL(sa.Line2, '') as [Shipping Line 2]
		,ISNULL(sa.City, '') as [Shipping City]
		,ISNULL(sa.Country, '') as [Shipping Country]
		,ISNULL(sa.State, '') as [Shipping State]
		,ISNULL(sa.PostalZip, '') as [Shipping Postal Zip]

		/** Address End **/

		/** Email Preference Start **/
		,CASE WHEN COALESCE(cepca.Enabled, aetcepca.[Enabled]) = 1 	   THEN 'true' ELSE 'false' END as [Email - Customer Activation]
		,CASE WHEN COALESCE(cepcc.Enabled, aetcepcc.[Enabled]) = 1 	   THEN 'true' ELSE 'false' END as [Email - Credential Create]
		,CASE WHEN COALESCE(cepcpr.Enabled, aetcepcpr.[Enabled]) = 1   THEN 'true' ELSE 'false' END as [Email - Credential Password Reset] 
		,CASE WHEN COALESCE(cepcs.Enabled, aetcepcs.[Enabled]) = 1     THEN 'true' ELSE 'false' END as [Email - Customer Suspend] 
		,CASE WHEN COALESCE(cepdi.Enabled, aetcepdi.[Enabled]) = 1     THEN 'true' ELSE 'false' END as [Email - Draft Invoice] 
		,CASE WHEN COALESCE(cepio.Enabled, aetcepio.[Enabled]) = 1     THEN 'true' ELSE 'false' END as [Email - Invoice Overdue] 
		,CASE WHEN COALESCE(cepip.Enabled, aetcepip.[Enabled]) = 1     THEN 'true' ELSE 'false' END as [Email - Invoice Post] 
		,CASE WHEN COALESCE(cepsn.Enabled, aetcepsn.[Enabled]) = 1     THEN 'true' ELSE 'false' END as [Email - Statement Notification] 
		,CASE WHEN COALESCE(cepubn.Enabled, aetcepubn.[Enabled]) = 1   THEN 'true' ELSE 'false' END as [Email - Upcoming Billing Notification] 
		,CASE WHEN COALESCE(cepcce.Enabled, aetcepcce.[Enabled]) = 1   THEN 'true' ELSE 'false' END as [Email - Credit Card Expiry] 
		,CASE WHEN COALESCE(ceppf.Enabled, aetceppf.[Enabled]) = 1     THEN 'true' ELSE 'false' END as [Email - Payment Failed] 
		,CASE WHEN COALESCE(ceppmu.Enabled, aetceppmu.[Enabled]) = 1   THEN 'true' ELSE 'false' END as [Email - Payment Method Update] 
		,CASE WHEN COALESCE(ceppr.Enabled, aetceppr.[Enabled]) = 1     THEN 'true' ELSE 'false' END as [Email - Payment Received] 
		,CASE WHEN COALESCE(cepr.Enabled, aetcepr.[Enabled]) = 1       THEN 'true' ELSE 'false' END as [Email - Refund] 
		,CASE WHEN COALESCE(ceppern.Enabled, aetceppern.[Enabled]) = 1 THEN 'true' ELSE 'false' END as [Email - Pending Expiry Renewal Notice] 
		,CASE WHEN COALESCE(cepsa.Enabled, aetcepsa.[Enabled]) = 1     THEN 'true' ELSE 'false' END as [Email - Subscription Activation] 
		,CASE WHEN COALESCE(cepsc.Enabled, aetcepsc.[Enabled]) = 1     THEN 'true' ELSE 'false' END as [Email - Subscription Cancellation] 
		/** Email Preference End **/

	FROM Customer c
	LEFT JOIN ParentCustomers parents ON c.Id = parents.ParentId
	INNER JOIN Lookup.CustomerStatus customerStatus ON c.StatusId = customerStatus.Id 
	LEFT JOIN Lookup.QuickBooksLatchType qblt on qblt.Id = c.QuickBooksLatchTypeId
	LEFT JOIN Lookup.SalesforceAccountType sfat on sfat.Id = c.SalesforceAccountTypeId
	LEFT JOIN Lookup.SalesforceSynchStatus sfss on sfss.Id = c.SalesforceSynchStatusId
	LEFT JOIN Lookup.SalesforceSynchStatus nsss on nsss.Id = c.NetsuiteSynchStatusId

	INNER JOIN dbo.CustomerAccountStatusJournal AS cj ON c.Id = cj.CustomerId AND cj.IsActive = 1
	INNER JOIN AccountPreference ap ON ap.Id = c.AccountId

	---- Contact Joins
	INNER JOIN Lookup.CustomerAccountStatus customerAccountStatus ON c.AccountStatusId = CustomerAccountStatus.Id 
	LEFT JOIN dbo.CustomerCredential cred on c.Id = cred.Id
	LEFT JOIN Lookup.Title title on c.TitleId = title.Id
	INNER Join Lookup.Currency currency on c.CurrencyId = currency.Id
	INNER JOIN AccountFeatureConfiguration afc on afc.Id = c.AccountId	

	---- BILLING JOINS
	INNER JOIN CustomerBillingSetting cbs on cbs.Id = c.Id
	INNER JOIN Lookup.Term term ON cbs.TermId = term.Id
	INNER JOIN AccountBillingPreference abp on abp.Id = c.AccountId
	INNER JOIN CustomerBillingStatementSetting cbss on c.id = cbss.Id
	LEFT JOIN dbo.PaymentMethod AS pm ON pm.Id = cbs.DefaultPaymentMethodId 
	INNER JOIN AccountAddressPreference aap on c.AccountId = aap.Id
	LEFT JOIN Lookup.RechargeType rt on cbs.RechargeTypeId = rt.Id
	LEFT JOIN CreditCard cc on pm.Id = cc.Id
	INNER JOIN CustomerInvoiceSetting cis on c.Id = cis.Id
	LEFT JOIN Lookup.TrackedItemDisplayFormat tidf on cis.TrackedItemDisplayFormatId = tidf.Id
	INNER JOIN AccountBillingPeriodConfiguration abpcm on abp.Id = abpcm.AccountBillingPreferenceId and abpcm.IntervalId = 3
	INNER JOIN AccountBillingPeriodConfiguration abpcy on abp.Id = abpcy.AccountBillingPreferenceId and abpcy.IntervalId = 5
	LEFT JOIN CustomerBillingPeriodConfiguration cbpcm on c.Id = cbpcm.CustomerBillingSettingId and cbpcm.IntervalId = 3
	LEFT JOIN CustomerBillingPeriodConfiguration cbpcy on c.Id = cbpcy.CustomerBillingSettingId and cbpcy.IntervalId = 5
	LEFT JOIN Lookup.BillingPeriodType bptm on bptm.Id = cbpcm.TypeId 
 	LEFT JOIN Lookup.BillingPeriodType bpty on bpty.Id = cbpcy.TypeId 
	LEFT JOIN Lookup.BillingPeriodRule bprm on bprm.Id = cbpcm.RuleId 
 	LEFT JOIN Lookup.BillingPeriodRule bpry on bpry.Id = cbpcy.RuleId 
	LEFT JOIN Lookup.BillingPeriodType abptm on abptm.Id = abpcm.TypeId 
 	LEFT JOIN Lookup.BillingPeriodType abpty on abpty.Id = abpcy.TypeId 
	LEFT JOIN Lookup.BillingPeriodRule abprm on abprm.Id = abpcm.RuleId 
 	LEFT JOIN Lookup.BillingPeriodRule abpry on abpry.Id = abpcy.RuleId 
	LEFT JOIN CustomerStartingData csd on c.id = csd.Id

	--Address Joins
	INNER JOIN CustomerAddressPreference cap ON cap.Id = c.Id
	LEFT JOIN [Address] ba on ba.CustomerAddressPreferenceId = c.Id and ba.AddressTypeId = 1 -- billing
	LEFT JOIN [Address] sa on sa.CustomerAddressPreferenceId = c.Id and sa.AddressTypeId = 2 -- shipping

	--Email Preference
	INNER JOIN CustomerEmailPreference cepca on cepca.CustomerId = c.Id and cepca.EmailType = 7
	INNER JOIN CustomerEmailPreference cepcc on cepcc.CustomerId = c.Id and cepcc.EmailType = 10
	INNER JOIN CustomerEmailPreference cepcpr on cepcpr.CustomerId = c.Id and cepcpr.EmailType = 11
	INNER JOIN CustomerEmailPreference cepcs on cepcs.CustomerId = c.Id and cepcs.EmailType = 12
	INNER JOIN CustomerEmailPreference cepdi on cepdi.CustomerId = c.Id and cepdi.EmailType = 21
	INNER JOIN CustomerEmailPreference cepio on cepio.CustomerId = c.Id and cepio.EmailType = 3
	INNER JOIN CustomerEmailPreference cepip on cepip.CustomerId = c.Id and cepip.EmailType = 1
	INNER JOIN CustomerEmailPreference cepsn on cepsn.CustomerId = c.Id and cepsn.EmailType = 15
	INNER JOIN CustomerEmailPreference cepubn on cepubn.CustomerId = c.Id and cepubn.EmailType = 16
	INNER JOIN CustomerEmailPreference cepcce on cepcce.CustomerId = c.Id and cepcce.EmailType = 14
	INNER JOIN CustomerEmailPreference ceppf on ceppf.CustomerId = c.Id and ceppf.EmailType = 6
	INNER JOIN CustomerEmailPreference ceppmu on ceppmu.CustomerId = c.Id and ceppmu.EmailType = 13
	INNER JOIN CustomerEmailPreference ceppr on ceppr.CustomerId = c.Id and ceppr.EmailType = 2
	INNER JOIN CustomerEmailPreference cepr on cepr.CustomerId = c.Id and cepr.EmailType = 17
	INNER JOIN CustomerEmailPreference ceppern on ceppern.CustomerId = c.Id and ceppern.EmailType = 18
	INNER JOIN CustomerEmailPreference cepsa on cepsa.CustomerId = c.Id and cepsa.EmailType = 8
	INNER JOIN CustomerEmailPreference cepsc on cepsc.CustomerId = c.Id and cepsc.EmailType = 9
	INNER JOIN AccountEmailTemplate aetcepca on aetcepca.AccountId = c.AccountId and aetcepca.TypeId = cepca.EmailType
	INNER JOIN AccountEmailTemplate aetcepcc on aetcepcc.AccountId = c.AccountId and aetcepcc.TypeId = cepcc.EmailType
	INNER JOIN AccountEmailTemplate aetcepcpr on aetcepcpr.AccountId = c.AccountId and aetcepcpr.TypeId = cepcpr.EmailType
	INNER JOIN AccountEmailTemplate aetcepcs on aetcepcs.AccountId = c.AccountId and aetcepcs.TypeId = cepcs.EmailType
	INNER JOIN AccountEmailTemplate aetcepdi on aetcepdi.AccountId = c.AccountId and aetcepdi.TypeId = cepdi.EmailType
	INNER JOIN AccountEmailTemplate aetcepio on aetcepio.AccountId = c.AccountId and aetcepio.TypeId = cepio.EmailType
	INNER JOIN AccountEmailTemplate aetcepip on aetcepip.AccountId = c.AccountId and aetcepip.TypeId = cepip.EmailType
	INNER JOIN AccountEmailTemplate aetcepsn on aetcepsn.AccountId = c.AccountId and aetcepsn.TypeId = cepsn.EmailType
	INNER JOIN AccountEmailTemplate aetcepubn on aetcepubn.AccountId = c.AccountId and aetcepubn.TypeId = cepubn.EmailType
	INNER JOIN AccountEmailTemplate aetcepcce on aetcepcce.AccountId = c.AccountId and aetcepcce.TypeId = cepcce.EmailType
	INNER JOIN AccountEmailTemplate aetceppf on aetceppf.AccountId = c.AccountId and aetceppf.TypeId = ceppf.EmailType
	INNER JOIN AccountEmailTemplate aetceppmu on aetceppmu.AccountId = c.AccountId and aetceppmu.TypeId = ceppmu.EmailType
	INNER JOIN AccountEmailTemplate aetceppr on aetceppr.AccountId = c.AccountId and aetceppr.TypeId = ceppr.EmailType
	INNER JOIN AccountEmailTemplate aetcepr on aetcepr.AccountId = c.AccountId and aetcepr.TypeId = cepr.EmailType
	INNER JOIN AccountEmailTemplate aetceppern on aetceppern.AccountId = c.AccountId and aetceppern.TypeId = ceppern.EmailType
	INNER JOIN AccountEmailTemplate aetcepsa on aetcepsa.AccountId = c.AccountId and aetcepsa.TypeId = cepsa.EmailType
	INNER JOIN AccountEmailTemplate aetcepsc on aetcepsc.AccountId = c.AccountId and aetcepsc.TypeId = cepsc.EmailType


	-- Tracking 
	INNER JOIN CustomerReference cr ON cr.Id = c.Id
	LEFT JOIN SalesTrackingCode stc1 on cr.SalesTrackingCode1Id = stc1.Id
	LEFT JOIN SalesTrackingCode stc2 on cr.SalesTrackingCode2Id = stc2.Id
	LEFT JOIN SalesTrackingCode stc3 on cr.SalesTrackingCode3Id = stc3.Id
	LEFT JOIN SalesTrackingCode stc4 on cr.SalesTrackingCode4Id = stc4.Id
	LEFT JOIN SalesTrackingCode stc5 on cr.SalesTrackingCode5Id = stc5.Id
	INNER JOIN CustomerAcquisition ca on ca.Id = cr.Id	

	WHERE c.AccountId = @AccountId

)

GO

