
CREATE VIEW [dbo].[vw_CustomerSummary]
AS
	WITH TodayInAccountTimezone AS (
		SELECT 
			DATEFROMPARTS(YEAR(dbo.fn_GetTimezoneTime(GETUTCDATE(),tz.Id)), MONTH(dbo.fn_GetTimezoneTime(GETUTCDATE(),tz.Id)), 1) as StartOfMonth
		, ap.Id as AccountId
		FROM AccountPreference ap
		INNER JOIN Lookup.Timezone tz ON tz.Id = ap.TimezoneId
	)
    SELECT TOP (100) PERCENT dbo.Customer.Id, dbo.Customer.ParentId, dbo.Customer.IsParent, dbo.Customer.Reference, dbo.Customer.TitleId, dbo.Customer.FirstName, dbo.Customer.MiddleName, dbo.Customer.LastName, dbo.Customer.Suffix, 
                      dbo.Customer.ArBalance, dbo.Customer.EffectiveTimestamp AS CreatedTimestamp, dbo.Customer.AccountId, 
                      dbo.Customer.PrimaryEmail, dbo.Customer.PrimaryPhone, dbo.Customer.SecondaryEmail, dbo.Customer.SecondaryPhone, dbo.Customer.NextBillingDate, dbo.Customer.CompanyName, 
                      dbo.Customer.StatusId AS CustomerStatusId, dbo.Customer.AccountStatusId AS CustomerAccountStatusId, Lookup.CustomerAccountStatus.Name AS AccountingStatus, Lookup.CustomerStatus.Name AS Status, dbo.Customer.CurrencyId, 
					  CASE WHEN cbs.AutoPostDraftInvoice IS NULL THEN bp.AutoPostDraftInvoice ELSE cbs.AutoPostDraftInvoice END as AutoPostDraftInvoice,
					  CASE WHEN cbs.AutoCollect IS NULL THEN bp.DefaultAutoCollect ELSE cbs.AutoCollect END as AutoCollect,
                      cr.Reference1, cr.Reference2, cr.Reference3, ca.AdContent, ca.Campaign, ca.Keyword, ca.LandingPage, ca.Medium, ca.Source,
					  CASE 
						WHEN bp.AutoSuspendEnabled = 1 AND 
							dbo.Customer.AccountStatusId = 2 
						AND 
							dbo.Customer.StatusId = 2 
						THEN 	
							(isnull(cbs.CustomerGracePeriod, isnull(bp.AccountGracePeriod, 0)) + isnull(cbs.GracePeriodExtension, 0) - (DATEDIFF(hh,cj.EffectiveTimestamp, GETUTCDATE()) / 24)) 
						ELSE 
							NULL
				      END AS DaysUntilSuspension, 
					  CASE 
						WHEN bp.AutoSuspendEnabled = 1 AND 
							dbo.Customer.AccountStatusId = 2 
						AND 
							dbo.Customer.StatusId = 5 
						THEN 	
							(coalesce(cbs.CustomerAutoCancel, bp.AccountAutoCancel) - (DATEDIFF(hh,csj.EffectiveTimestamp, GETUTCDATE()) / 24)) 
						ELSE 
							NULL
				      END AS DaysUntilCancellation, 
					  Lookup.Term.Name AS Terms, 
                      CASE WHEN (cbs.AutoCollect = 1 OR
                      (cbs.AutoCollect IS NULL AND bp.DefaultAutoCollect = 1)) AND pm.Id IS NULL THEN 'Missing' WHEN (cbs.AutoCollect = 1 OR
                      (cbs.AutoCollect IS NULL AND bp.DefaultAutoCollect = 1)) AND pm.Id IS NOT NULL AND pm.PaymentMethodTypeId = 3 THEN 'Credit Card' 
					  WHEN (cbs.AutoCollect = 1 OR (cbs.AutoCollect IS NULL AND bp.DefaultAutoCollect = 1)) AND pm.Id IS NOT NULL AND pm.PaymentMethodTypeId = 5 THEN 'ACH' 
					  WHEN (cbs.AutoCollect = 1 OR (cbs.AutoCollect IS NULL AND bp.DefaultAutoCollect = 1)) AND pm.Id IS NOT NULL AND pm.PaymentMethodTypeId = 6 THEN 'Paypal' 
					  WHEN (cbs.AutoCollect = 0 OR (cbs.AutoCollect IS NULL AND bp.DefaultAutoCollect = 0)) AND pm.Id IS NOT NULL THEN 'AR - Pay method on file' 
					  WHEN pm.Id IS NULL THEN 'AR' END AS PaymentMethod, 

					  CASE WHEN cbs.DefaultPaymentMethodId IS NULL AND COALESCE(cbs.AutoCollect, bp.DefaultAutoCollect) = 1 THEN 'Missing' 
					  WHEN cbs.DefaultPaymentMethodId IS NOT NULL AND (
						cc.Id IS NULL OR
							DATEFROMPARTS(cc.ExpirationYear + 2000, cc.ExpirationMonth, 1) >
								DATEADD(month, 2, today.StartOfMonth) -- Expiry is greater than 3 months
						) THEN 'PaymentMethodOnFile' 
						WHEN cbs.DefaultPaymentMethodId IS NOT NULL AND cc.Id IS NOT NULL AND 
							DATEFROMPARTS(cc.ExpirationYear + 2000, cc.ExpirationMonth, 1) =
								DATEADD(month, 2, today.StartOfMonth) -- Expiry is in 2 months
						THEN 'ExpireInTwoMonths'  
						WHEN cbs.DefaultPaymentMethodId IS NOT NULL AND cc.Id IS NOT NULL AND 
							DATEFROMPARTS(cc.ExpirationYear + 2000, cc.ExpirationMonth, 1) =
								DATEADD(month, 1, today.StartOfMonth) -- Expiry is in 1 month
						THEN 'ExpireInOneMonth'  
						WHEN cbs.DefaultPaymentMethodId IS NOT NULL AND cc.Id IS NOT NULL AND 
							DATEFROMPARTS(cc.ExpirationYear + 2000, cc.ExpirationMonth, 1) =
								DATEADD(month, 0, today.StartOfMonth) -- Expiries this month
						THEN 'ExpiresThisMonth'  
						WHEN cbs.DefaultPaymentMethodId IS NOT NULL AND cc.Id IS NOT NULL AND 
							DATEFROMPARTS(cc.ExpirationYear + 2000, cc.ExpirationMonth, 1) <
								DATEADD(month, 0, today.StartOfMonth) -- Expiry is in 2 months
						THEN 'Expired'  
							END as PaymentMethodOnFile,
						CASE WHEN pm.PaymentMethodStatusId = 3 THEN CAST(1 as bit) ELSE CAST(0 as bit) END AS IsPaymentMethodDisabled,
						pm.PaymentMethodStatusDisabledTypeId,
					  CASE WHEN pm.CustomerId <> Customer.Id THEN CAST(1 as bit) ELSE CAST(0 as bit) END AS IsParentPaymentMethod,
					  CASE WHEN afc.MrrDisplayTypeId = 1 THEN dbo.Customer.MonthlyRecurringRevenue ELSE dbo.Customer.CurrentMrr END as MonthlyRecurringRevenue, 
                      dbo.Customer.SalesforceId, CASE WHEN afc.MrrDisplayTypeId = 1 THEN dbo.Customer.NetMRR ELSE dbo.Customer.CurrentNetMrr END as NetMRR, 
					  cc.MaskedCardNumber, dbo.Customer.NetsuiteId, cr.ClassicId
					,stc1.Id as [SalesTrackingCode1Id]
					  ,stc1.Code as [SalesTrackingCode1Code]
					,stc1.Name as [SalesTrackingCode1Name]
					,stc2.Id as [SalesTrackingCode2Id]
					,stc2.Code as [SalesTrackingCode2Code]
					,stc2.Name as [SalesTrackingCode2Name]
					,stc3.Id as [SalesTrackingCode3Id]
					,stc3.Code as [SalesTrackingCode3Code]
					,stc3.Name as [SalesTrackingCode3Name]
					,stc4.Id as [SalesTrackingCode4Id]
					,stc4.Code as [SalesTrackingCode4Code]
					,stc4.Name as [SalesTrackingCode4Name]
					,stc5.Id as [SalesTrackingCode5Id]
					,stc5.Code as [SalesTrackingCode5Code]
					,stc5.Name as [SalesTrackingCode5Name]
					,cap.ContactName, cap.ShippingInstructions, cap.UseBillingAddressAsShippingAddress
					,billing.CompanyName as BillingCompanyName, billing.Line1 as BillingLine1, billing.Line2 as BillingLine2
					,billing.City as BillingCity, billing.PostalZip as BillingPostalZip, billingCountry.Name as BillingCountry
					,billingState.Name as BillingState,billing.County as BillingCounty
					,shipping.CompanyName as ShippingCompanyName, shipping.Line1 as ShippingLine1, shipping.Line2 as ShippingLine2
					,shipping.City as ShippingCity, shipping.PostalZip as ShippingPostalZip, shippingCountry.Name as ShippingCountry, shippingState.Name as ShippingState
    FROM     dbo.Customer INNER JOIN
						TodayInAccountTimezone today ON today.AccountId = dbo.Customer.AccountId INNER JOIN
					  dbo.AccountFeatureConfiguration afc ON afc.Id = dbo.Customer.AccountId INNER JOIN 
					  dbo.CustomerStatusJournal AS csj ON dbo.Customer.Id = csj.CustomerId AND csj.IsActive = 1 INNER JOIN
                      dbo.CustomerAccountStatusJournal AS cj ON dbo.Customer.Id = cj.CustomerId AND cj.IsActive = 1 INNER JOIN
                      dbo.CustomerBillingSetting AS cbs ON dbo.Customer.Id = cbs.Id INNER JOIN
                      dbo.AccountBillingPreference AS bp ON dbo.Customer.AccountId = bp.Id INNER JOIN
					  dbo.CustomerAddressPreference AS cap  on dbo.Customer.Id = cap.Id 
					  left join [Address] billing ON cap.Id = billing.CustomerAddressPreferenceId AND billing.AddressTypeId = 1
					  left join Lookup.Country billingCountry ON billingCountry.Id = billing.CountryId
					  left join Lookup.State billingState ON billingState.Id = billing.StateId
					  left join [Address] shipping ON cap.Id = shipping.CustomerAddressPreferenceId AND shipping.AddressTypeId = 2
					  left join Lookup.Country shippingCountry ON shippingCountry.Id = shipping.CountryId
					  left join Lookup.State shippingState ON shippingState.Id = shipping.StateId
					  INNER JOIN
					  Lookup.CustomerStatus ON dbo.Customer.StatusId = Lookup.CustomerStatus.Id INNER JOIN
                      Lookup.CustomerAccountStatus ON dbo.Customer.AccountStatusId = Lookup.CustomerAccountStatus.Id INNER JOIN
                      Lookup.Term ON cbs.TermId = Lookup.Term.Id LEFT OUTER JOIN
                      dbo.CustomerAcquisition AS ca ON ca.Id = dbo.Customer.Id LEFT OUTER JOIN
                      dbo.CustomerReference AS cr ON cr.Id = dbo.Customer.Id 
					  left join SalesTrackingCode stc1
						on cr.SalesTrackingCode1Id = stc1.Id
						left join SalesTrackingCode stc2
						on cr.SalesTrackingCode2Id = stc2.Id
						left join SalesTrackingCode stc3
						on cr.SalesTrackingCode3Id = stc3.Id
						left join SalesTrackingCode stc4
						on cr.SalesTrackingCode4Id = stc4.Id
						left join SalesTrackingCode stc5
						on cr.SalesTrackingCode5Id = stc5.Id
					  LEFT OUTER JOIN dbo.PaymentMethod AS PM ON PM.Id = cbs.DefaultPaymentMethodId 
					  LEFT OUTER JOIN dbo.CreditCard AS cc ON cc.Id = PM.Id
					  WHERE dbo.Customer.IsDeleted = 0

GO

