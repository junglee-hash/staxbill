CREATE   PROCEDURE [dbo].[usp_DeleteRecordsFromTemporaryAccount]
	@accountResetId bigint,
	@originalAccountId bigint,
	@temporaryAccountId bigint,
	@customerIdsToExclude varchar(2000)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	BEGIN TRY

		declare @customers as CustomerSplitTableType
	
		INSERT INTO @customers (CustomerId)
		select Data from dbo.Split (@customerIdsToExclude,',')

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'InstantPaymentNotification'
					, 'INNER JOIN Customer c ON c.Id = tn.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'FusebillSupportLogin'
					, 'INNER JOIN Customer c ON c.Id = tn.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'AchCard'
					, 'INNER JOIN PaymentMethod pm ON pm.Id = tn.Id INNER JOIN Customer c ON c.Id = pm.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'Address'
					, 'INNER JOIN Customer c ON c.Id = tn.CustomerAddressPreferenceId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'AuditTrail'
					, ''
					, 'tn'
					, 0

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'AvalaraLog'
					, ''
					, 'tn'
					, 0

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'ChargeLastEarning'
					, 'INNER JOIN [Transaction] t ON t.Id = tn.Id INNER JOIN Customer c ON c.Id = t.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'ReverseTax'
					, 'INNER JOIN [Transaction] t ON t.Id = tn.Id INNER JOIN Customer c ON c.Id = t.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'ReverseEarning'
					, 'INNER JOIN [Transaction] t ON t.Id = tn.Id INNER JOIN Customer c ON c.Id = t.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'ReverseDiscount'
					, 'INNER JOIN [Transaction] t ON t.Id = tn.Id INNER JOIN Customer c ON c.Id = t.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'ReverseCharge'
					, 'INNER JOIN [Transaction] t ON t.Id = tn.Id INNER JOIN Customer c ON c.Id = t.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'EarningDiscount'
					, 'INNER JOIN [Transaction] t ON t.Id = tn.Id INNER JOIN Customer c ON c.Id = t.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'EarningOpeningDeferredRevenue'
					, 'INNER JOIN [Transaction] t ON t.Id = tn.Id INNER JOIN Customer c ON c.Id = t.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'Earning'
					, 'INNER JOIN [Transaction] t ON t.Id = tn.Id INNER JOIN Customer c ON c.Id = t.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'SubscriptionProductActivityJournalCharge'
					, 'INNER JOIN [Transaction] t ON t.Id = tn.ChargeId INNER JOIN Customer c ON c.Id = t.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'SubscriptionProductCharge'
					, 'INNER JOIN [Transaction] t ON t.Id = tn.Id INNER JOIN Customer c ON c.Id = t.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'Discount'
					, 'INNER JOIN [Transaction] t ON t.Id = tn.Id INNER JOIN Customer c ON c.Id = t.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'ChargeProductItem'
					, 'INNER JOIN [Transaction] t ON t.Id = tn.ChargeId INNER JOIN Customer c ON c.Id = t.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'ChargeTier'
					, 'INNER JOIN [Transaction] t ON t.Id = tn.ChargeId INNER JOIN Customer c ON c.Id = t.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'CollectionScheduleActivity'
					, 'INNER JOIN Customer c ON c.Id = tn.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'DebitAllocation'
					, 'INNER JOIN Invoice i ON i.Id = tn.InvoiceId INNER JOIN Customer c ON c.Id = i.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'Debit'
					, 'INNER JOIN [Transaction] t ON t.Id = tn.Id INNER JOIN Customer c ON c.Id = t.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'CreditAllocation'
					, 'INNER JOIN Invoice i ON i.Id = tn.InvoiceId INNER JOIN Customer c ON c.Id = i.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'Credit'
					, 'INNER JOIN [Transaction] t ON t.Id = tn.Id INNER JOIN Customer c ON c.Id = t.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'CreditCardExpiryActivity'
					, 'INNER JOIN PaymentMethod pm ON pm.Id = tn.CreditCardId INNER JOIN Customer c ON c.Id = pm.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'CreditCard'
					, 'INNER JOIN PaymentMethod pm ON pm.Id = tn.Id INNER JOIN Customer c ON c.Id = pm.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'CreditNote'
					, 'INNER JOIN Invoice i ON i.Id = tn.InvoiceId INNER JOIN Customer c ON c.Id = i.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'CreditNoteGroup'
					, 'INNER JOIN Invoice i ON i.Id = tn.InvoiceId INNER JOIN Customer c ON c.Id = i.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'Dispute'
					, 'INNER JOIN Invoice i ON i.Id = tn.InvoiceId INNER JOIN Customer c ON c.Id = i.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'DraftChargeProductItem'
					, 'INNER JOIN DraftCharge dc ON dc.Id = tn.DraftChargeId INNER JOIN Customer c ON c.Id = dc.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'DraftChargeTier'
					, 'INNER JOIN DraftCharge dc ON dc.Id = tn.DraftChargeId INNER JOIN Customer c ON c.Id = dc.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'SubscriptionProductActivityJournalDraftCharge'
					, 'INNER JOIN DraftCharge dc ON dc.Id = tn.DraftChargeId INNER JOIN Customer c ON c.Id = dc.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'DraftDiscount'
					, 'INNER JOIN DraftCharge dc ON dc.Id = tn.DraftChargeId INNER JOIN Customer c ON c.Id = dc.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'DraftPaymentSchedule'
					, 'INNER JOIN DraftInvoice dc ON dc.Id = tn.DraftInvoiceId INNER JOIN Customer c ON c.Id = dc.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'DraftPurchaseCharge'
					, 'INNER JOIN DraftCharge dc ON dc.Id = tn.Id INNER JOIN Customer c ON c.Id = dc.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'DraftSubscriptionProductCharge'
					, 'INNER JOIN DraftCharge dc ON dc.Id = tn.Id INNER JOIN Customer c ON c.Id = dc.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'DraftTax'
					, 'INNER JOIN DraftInvoice dc ON dc.Id = tn.DraftInvoiceId INNER JOIN Customer c ON c.Id = dc.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'DraftCharge'
					, 'INNER JOIN Customer c ON c.Id = tn.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'ProjectedInvoice'
					, 'INNER JOIN Customer c ON c.Id = tn.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'CustomerEmailLogAttachment'
					, 'INNER JOIN CustomerEmailLog cel ON cel.Id = tn.CustomerEmailLogId INNER JOIN Customer c ON c.Id = cel.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'CustomerEmailLogBillingStatement'
					, 'INNER JOIN CustomerEmailLog cel ON cel.Id = tn.CustomerEmailLogId INNER JOIN Customer c ON c.Id = cel.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'CustomerEmailLogDraftInvoice'
					, 'INNER JOIN CustomerEmailLog cel ON cel.Id = tn.CustomerEmailLogId INNER JOIN Customer c ON c.Id = cel.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'CustomerEmailLogInvoice'
					, 'INNER JOIN CustomerEmailLog cel ON cel.Id = tn.CustomerEmailLogId INNER JOIN Customer c ON c.Id = cel.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'CustomerEmailLog'
					, 'INNER JOIN Customer c ON c.Id = tn.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'CustomerSmsNumber'
					, 'INNER JOIN Customer c ON c.Id = tn.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'CustomerTxtPreference'
					, 'INNER JOIN Customer c ON c.Id = tn.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'CustomerIntegration'
					, 'INNER JOIN Customer c ON c.Id = tn.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'DraftInvoice'
					, 'INNER JOIN Customer c ON c.Id = tn.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'IntegrationSynchBatchRecord'
					, 'INNER JOIN IntegrationSynchBatch isa ON isa.Id = tn.IntegrationSynchBatchId INNER JOIN IntegrationSynchJob i ON i.Id = isa.IntegrationSynchJobId'
					, 'i'
					, 0

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'IntegrationSynchBatch'
					, 'INNER JOIN IntegrationSynchJob i ON i.Id = tn.IntegrationSynchJobId'
					, 'i'
					, 0

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'IntegrationSynchJob'
					, ''
					, 'tn'
					, 0

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'QuickBooksLog'
					, ''
					, 'tn'
					, 0

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'UnknownPaymentJournal'
					, ''
					, 'tn'
					, 0

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'PurchaseCharge'
					, 'INNER JOIN Purchase p ON p.Id = tn.PurchaseId INNER JOIN Customer c ON c.Id = p.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'PurchaseCouponCode'
					, 'INNER JOIN Purchase p ON p.Id = tn.PurchaseId INNER JOIN Customer c ON c.Id = p.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'PurchaseCustomField'
					, 'INNER JOIN Purchase p ON p.Id = tn.PurchaseId INNER JOIN Customer c ON c.Id = p.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'PurchaseDiscount'
					, 'INNER JOIN Purchase p ON p.Id = tn.PurchaseId INNER JOIN Customer c ON c.Id = p.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'PurchasePriceRange'
					, 'INNER JOIN Purchase p ON p.Id = tn.PurchaseId INNER JOIN Customer c ON c.Id = p.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'PurchaseProductItem'
					, 'INNER JOIN Purchase p ON p.Id = tn.PurchaseId INNER JOIN Customer c ON c.Id = p.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'Purchase'
					, 'INNER JOIN Customer c ON c.Id = tn.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'Tax'
					, 'INNER JOIN [Transaction] t ON t.Id = tn.Id INNER JOIN Customer c ON c.Id = t.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'WriteOff'
					, 'INNER JOIN [Transaction] t ON t.Id = tn.Id INNER JOIN Customer c ON c.Id = t.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'Charge'
					, 'INNER JOIN [Transaction] t ON t.Id = tn.Id INNER JOIN Customer c ON c.Id = t.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'ChargeGroup'
					, 'INNER JOIN Invoice i ON i.Id = tn.InvoiceId INNER JOIN Customer c ON c.Id = i.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'ScheduledMigration'
					, 'INNER JOIN Customer c ON c.Id = tn.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'SelfServicePortalToken'
					, 'INNER JOIN Customer c ON c.Id = tn.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'SubscriptionStatusJournal'
					, 'INNER JOIN Subscription s ON s.Id = tn.SubscriptionId INNER JOIN Customer c ON c.Id = s.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'SubscriptionProductStartingData'
					, 'INNER JOIN SubscriptionProduct sp ON sp.Id = tn.Id INNER JOIN Subscription s ON s.Id = sp.SubscriptionId INNER JOIN Customer c ON c.Id = s.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'SubscriptionProductOverride'
					, 'INNER JOIN SubscriptionProduct sp ON sp.Id = tn.Id INNER JOIN Subscription s ON s.Id = sp.SubscriptionId INNER JOIN Customer c ON c.Id = s.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'SubscriptionProductPriceUplift'
					, 'INNER JOIN SubscriptionProduct sp ON sp.Id = tn.SubscriptionProductId INNER JOIN Subscription s ON s.Id = sp.SubscriptionId INNER JOIN Customer c ON c.Id = s.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'SubscriptionProductPriceRange'
					, 'INNER JOIN SubscriptionProduct sp ON sp.Id = tn.SubscriptionProductId INNER JOIN Subscription s ON s.Id = sp.SubscriptionId INNER JOIN Customer c ON c.Id = s.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'SubscriptionProductJournal'
					, 'INNER JOIN SubscriptionProduct sp ON sp.Id = tn.SubscriptionProductId INNER JOIN Subscription s ON s.Id = sp.SubscriptionId INNER JOIN Customer c ON c.Id = s.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'SubscriptionProductItem'
					, 'INNER JOIN SubscriptionProduct sp ON sp.Id = tn.SubscriptionProductId INNER JOIN Subscription s ON s.Id = sp.SubscriptionId INNER JOIN Customer c ON c.Id = s.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'SubscriptionProductDiscount'
					, 'INNER JOIN SubscriptionProduct sp ON sp.Id = tn.SubscriptionProductId INNER JOIN Subscription s ON s.Id = sp.SubscriptionId INNER JOIN Customer c ON c.Id = s.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'SubscriptionProductCustomField'
					, 'INNER JOIN SubscriptionProduct sp ON sp.Id = tn.SubscriptionProductId INNER JOIN Subscription s ON s.Id = sp.SubscriptionId INNER JOIN Customer c ON c.Id = s.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'SubscriptionProductActivityJournal'
					, 'INNER JOIN SubscriptionProduct sp ON sp.Id = tn.SubscriptionProductId INNER JOIN Subscription s ON s.Id = sp.SubscriptionId INNER JOIN Customer c ON c.Id = s.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'PriceRangeOverride'
					, 'INNER JOIN PricingModelOverride pm ON pm.Id = tn.PricingModelOverrideId INNER JOIN SubscriptionProduct sp ON sp.Id = pm.Id INNER JOIN Subscription s ON s.Id = sp.SubscriptionId INNER JOIN Customer c ON c.Id = s.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'PricingModelOverride'
					, 'INNER JOIN SubscriptionProduct sp ON sp.Id = tn.Id INNER JOIN Subscription s ON s.Id = sp.SubscriptionId INNER JOIN Customer c ON c.Id = s.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'SubscriptionProduct'
					, 'INNER JOIN Subscription s ON s.Id = tn.SubscriptionId INNER JOIN Customer c ON c.Id = s.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'SubscriptionOverride'
					, 'INNER JOIN Subscription s ON s.Id = tn.Id INNER JOIN Customer c ON c.Id = s.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'SubscriptionCustomField'
					, 'INNER JOIN Subscription s ON s.Id = tn.SubscriptionId INNER JOIN Customer c ON c.Id = s.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'SubscriptionCouponCode'
					, 'INNER JOIN Subscription s ON s.Id = tn.SubscriptionId INNER JOIN Customer c ON c.Id = s.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'Migration'
					, 'INNER JOIN Customer c ON c.Id = tn.FusebillId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'Subscription'
					, 'INNER JOIN Customer c ON c.Id = tn.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'OpeningBalanceAllocation'
					, 'INNER JOIN Invoice i ON i.Id = tn.InvoiceId INNER JOIN Customer c ON c.Id = i.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'OpeningBalance'
					, 'INNER JOIN [Transaction] t ON t.Id = tn.Id INNER JOIN Customer c ON c.Id = t.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'RefundNote'
					, 'INNER JOIN Invoice i ON i.Id = tn.InvoiceId INNER JOIN Customer c ON c.Id = i.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'Refund'
					, 'INNER JOIN [Transaction] t ON t.Id = tn.Id INNER JOIN Customer c ON c.Id = t.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'PaymentNote'
					, 'INNER JOIN Invoice i ON i.Id = tn.InvoiceId INNER JOIN Customer c ON c.Id = i.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'Payment'
					, 'INNER JOIN [Transaction] t ON t.Id = tn.Id INNER JOIN Customer c ON c.Id = t.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'OpeningDeferredRevenue'
					, 'INNER JOIN [Transaction] t ON t.Id = tn.Id INNER JOIN Customer c ON c.Id = t.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'Transaction'
					, 'INNER JOIN Customer c ON c.Id = tn.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'InvoiceAddress'
					, 'INNER JOIN Invoice i ON i.Id = tn.InvoiceId INNER JOIN Customer c ON c.Id = i.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'InvoiceCustomer'
					, 'INNER JOIN Invoice i ON i.Id = tn.InvoiceId INNER JOIN Customer c ON c.Id = i.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'InvoiceJournal'
					, 'INNER JOIN Invoice i ON i.Id = tn.InvoiceId INNER JOIN Customer c ON c.Id = i.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'PaymentScheduleJournal'
					, 'INNER JOIN PaymentSchedule ps ON ps.Id = tn.PaymentScheduleId INNER JOIN Invoice i ON i.Id = ps.InvoiceId INNER JOIN Customer c ON c.Id = i.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'PaymentSchedule'
					, 'INNER JOIN Invoice i ON i.Id = tn.InvoiceId INNER JOIN Customer c ON c.Id = i.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'Invoice'
					, 'INNER JOIN Customer c ON c.Id = tn.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'BillingPeriod'
					, 'INNER JOIN Customer c ON c.Id = tn.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'BillingPeriodDefinition'
					, 'INNER JOIN Customer c ON c.Id = tn.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'CustomerBillingPeriodConfiguration'
					, 'INNER JOIN Customer c ON c.Id = tn.CustomerBillingSettingId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'CustomerBillingSetting'
					, 'INNER JOIN Customer c ON c.Id = tn.Id'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'PaymentActivityJournal'
					, 'INNER JOIN Customer c ON c.Id = tn.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'PaymentMethod'
					, 'INNER JOIN Customer c ON c.Id = tn.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'ProductItem'
					, 'INNER JOIN Customer c ON c.Id = tn.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'CustomerAccountStatusJournal'
					, 'INNER JOIN Customer c ON c.Id = tn.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'CustomerAcquisition'
					, 'INNER JOIN Customer c ON c.Id = tn.Id'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'CustomerAddressPreference'
					, 'INNER JOIN Customer c ON c.Id = tn.Id'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'CustomerBillingStatementSetting'
					, 'INNER JOIN Customer c ON c.Id = tn.Id'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'CustomerCredential'
					, 'INNER JOIN Customer c ON c.Id = tn.Id'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'CustomerEmailControl'
					, 'INNER JOIN Customer c ON c.Id = tn.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'BillingStatement'
					, 'INNER JOIN Customer c ON c.Id = tn.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'CustomerEmailPreference'
					, 'INNER JOIN Customer c ON c.Id = tn.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'CustomerInvoiceSetting'
					, 'INNER JOIN Customer c ON c.Id = tn.Id'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'CustomerNote'
					, 'INNER JOIN Customer c ON c.Id = tn.CustomerId'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'CustomerReference'
					, 'INNER JOIN Customer c ON c.Id = tn.Id'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'CustomerStartingData'
					, 'INNER JOIN Customer c ON c.Id = tn.Id'

		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'CustomerStatusJournal'
					, 'INNER JOIN Customer c ON c.Id = tn.CustomerId'





		EXECUTE [dbo].[usp_DeleteRecordsDynamically]
					@accountResetId
					, @temporaryAccountId
					, @customers
					, 'Customer'
					, ''
					, 'tn'

		-- Final clean up
		UPDATE AccountReset
		SET ResetEndTimestamp = GETUTCDATE(),
			StatusId = 5,
			TemporaryAccountId = null
		WHERE Id = @accountResetId

		DELETE FROM AccountFeatureConfiguration
		WHERE Id = @temporaryAccountId

		DELETE FROM Account
		WHERE Id = @temporaryAccountId

	END TRY

	BEGIN CATCH

       DECLARE @ErrorMessage NVARCHAR(4000);
       DECLARE @ErrorSeverity INT;
       DECLARE @ErrorState INT;

       SELECT 
              @ErrorMessage = ERROR_MESSAGE(),
              @ErrorSeverity = ERROR_SEVERITY(),
              @ErrorState = ERROR_STATE();

       RAISERROR 
       (
              @ErrorMessage, -- Message text.
              @ErrorSeverity, -- Severity.
              @ErrorState -- State.
       );
	END CATCH
END

GO

