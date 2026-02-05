CREATE FUNCTION [dbo].[CustomerExportCSVBilling]
(	
	@FusebillId as bigint,
--	@AccountId as bigint,
	@TimezoneId as int
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT 
	ISNULL(cbs.StandingPo, '') as [Standing PO]
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
	,ISNULL(CONVERT(varchar(20),convert(datetime,dbo.fn_GetTimezoneTime(c.NextBillingDate, @TimezoneId)), 120), '') as [Next Billing Date]
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

	FROM
	Customer c
	INNER JOIN dbo.CustomerAccountStatusJournal AS cj ON c.Id = cj.CustomerId AND cj.IsActive = 1

	---- BILLING JOINS
	INNER JOIN CustomerBillingSetting cbs on cbs.Id = c.Id
	INNER JOIN Lookup.Term term ON cbs.TermId = term.Id
	INNER JOIN AccountBillingPreference abp on abp.Id = c.AccountId
	INNER JOIN CustomerBillingStatementSetting cbss on c.id = cbss.Id
	LEFT JOIN dbo.PaymentMethod AS pm ON pm.Id = cbs.DefaultPaymentMethodId 
	LEFT JOIN AccountAddressPreference aap on c.AccountId = aap.Id
	LEFT JOIN Lookup.RechargeType rt on cbs.RechargeTypeId = rt.Id
	LEFT JOIN CreditCard cc on pm.Id = cc.Id
	LEFT JOIN CustomerInvoiceSetting cis on c.Id = cis.Id
	LEFT JOIN Lookup.TrackedItemDisplayFormat tidf on cis.TrackedItemDisplayFormatId = tidf.Id
	LEFT JOIN AccountBillingPeriodConfiguration abpcm on abp.Id = abpcm.AccountBillingPreferenceId and abpcm.IntervalId = 3
	LEFT JOIN AccountBillingPeriodConfiguration abpcy on abp.Id = abpcy.AccountBillingPreferenceId and abpcy.IntervalId = 5
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

	WHERE c.Id = @FusebillId
)

GO

