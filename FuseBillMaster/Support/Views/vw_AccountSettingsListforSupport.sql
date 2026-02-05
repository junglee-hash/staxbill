CREATE VIEW [Support].[vw_AccountSettingsListforSupport]
AS
SELECT        dbo.Account.Id, dbo.Account.CompanyName, dbo.Account.FusebillTest, dbo.Account.Signed, dbo.Account.Live, dbo.AccountBillingPreference.AutoPostDraftInvoice, dbo.AccountBillingPreference.AutoSuspendEnabled,
                         dbo.AccountBillingPreference.AccountGracePeriod, TER.Name AS DefaultTerm, dbo.AccountBillingPreference.DefaultAutoCollect, dbo.AccountBillingPreference.CustomerAcquisitionCost, 
                         dbo.AccountBillingPreference.ShowZeroDollarCharges, dbo.AccountBillingPreference.DefaultCustomerServiceStartOptionId, dbo.AccountBrandingPreference.CompanyName AS BrandingCompanyName, 
                         dbo.AccountBrandingPreference.Address1, dbo.AccountBrandingPreference.Address2, dbo.AccountBrandingPreference.City, dbo.AccountBrandingPreference.StateId, dbo.AccountBrandingPreference.CountryId, 
                         dbo.AccountBrandingPreference.PostalZip, dbo.AccountBrandingPreference.SupportEmail, dbo.AccountBrandingPreference.BillingEmail, dbo.AccountBrandingPreference.WebsiteLabel, 
                         dbo.AccountBrandingPreference.WebsiteUrl, dbo.AccountBrandingPreference.BillingPhone, dbo.AccountBrandingPreference.SupportPhone, dbo.AccountBrandingPreference.Fax, 
                         dbo.AccountBrandingPreference.FromEmail, dbo.AccountBrandingPreference.ReplyToEmail, dbo.AccountBrandingPreference.FromDisplay, dbo.AccountBrandingPreference.ReplyToDisplay, 
                         dbo.AccountBrandingPreference.BccEmail, dbo.AccountFeatureConfiguration.SalesforceEnabled, dbo.AccountFeatureConfiguration.SalesforceSandboxMode, dbo.AccountFeatureConfiguration.NetsuiteEnabled, 
                         dbo.AccountFeatureConfiguration.AvalaraOrganizationCode, dbo.AccountInvoicePreference.NextInvoiceNumber, dbo.AccountInvoicePreference.InvoiceSignature, 
                         dbo.AccountInvoicePreference.ShowShippingAddress, dbo.AccountInvoicePreference.InvoiceNote, dbo.AccountInvoicePreference.RollUpTaxes, dbo.AccountInvoicePreference.InvoiceCustomerReferenceOption,
						 lt.DisplayName AS Timezone, dbo.AccountFeatureConfiguration.QuickBooksEnabled
FROM            dbo.Account WITH (nolock) INNER JOIN
                         dbo.AccountBillingPreference WITH (nolock) ON dbo.Account.Id = dbo.AccountBillingPreference.Id INNER JOIN
                         dbo.AccountBrandingPreference WITH (nolock) ON dbo.AccountBillingPreference.Id = dbo.AccountBrandingPreference.Id INNER JOIN
                         dbo.AccountFeatureConfiguration WITH (nolock) ON dbo.Account.Id = dbo.AccountFeatureConfiguration.Id INNER JOIN
                         dbo.AccountInvoicePreference WITH (nolock) ON dbo.AccountBillingPreference.Id = dbo.AccountInvoicePreference.Id INNER JOIN
                         dbo.AccountPreference WITH (nolock) ON dbo.Account.Id = dbo.AccountPreference.Id INNER JOIN
                         Lookup.Term AS TER WITH (nolock) ON dbo.AccountBillingPreference.DefaultTermId = TER.Id INNER JOIN
                         Lookup.Timezone AS lt WITH (nolock) ON dbo.AccountPreference.TimezoneId = lt.Id

GO

