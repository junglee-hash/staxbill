CREATE procedure [dbo].[usp_CleanAutomationAccounts_Test]
--declare
@AccountId bigint = 0,
@PaymentPlatformDbName SYSNAME,
@CommPlatformDbName SYSNAME,
@OlderThanDate DATETIME = NULL

as

IF @OlderThanDate IS NULL
BEGIN
	SET @OlderThanDate = GETUTCDATE()
END

SET QUOTED_IDENTIFIER ON;

	IF DB_ID(@CommPlatformDbName) IS NULL  /*Validate the database name exists*/
       BEGIN
       RAISERROR('Invalid Comm Platform Database Name passed',16,1)
       RETURN
       END

BEGIN TRY

	--CREATE TEMP FK INDEXES TO OPTIMISE BULK DELETION

	IF EXISTS(SELECT * FROM sys.indexes WHERE object_id = object_id('dbo.SubscriptionProduct') AND NAME ='TEMP_FKIX_SubscriptionProduct_PlanProductId')
		DROP INDEX [TEMP_FKIX_SubscriptionProduct_PlanProductId] ON [dbo].[SubscriptionProduct]

		CREATE NONCLUSTERED INDEX [TEMP_FKIX_SubscriptionProduct_PlanProductId] ON [dbo].[SubscriptionProduct]
		([PlanProductId])

	IF EXISTS(SELECT * FROM sys.indexes WHERE object_id = object_id('dbo.PaymentActivityJournal') AND NAME ='TEMP_FKIX_PaymentActivityJournal_ParentCustomerId')
		DROP INDEX [TEMP_FKIX_PaymentActivityJournal_ParentCustomerId] ON [dbo].[PaymentActivityJournal]

		CREATE NONCLUSTERED INDEX [TEMP_FKIX_PaymentActivityJournal_ParentCustomerId] ON [dbo].[PaymentActivityJournal]
		([ParentCustomerId])

	IF EXISTS(SELECT * FROM sys.indexes WHERE object_id = object_id('dbo.PlanFamilyRelationshipMapping') AND NAME ='TEMP_FKIX_PlanFamilyRelationshipMapping_SourcePlanProductId')
		DROP INDEX [TEMP_FKIX_PlanFamilyRelationshipMapping_SourcePlanProductId] ON [dbo].[PlanFamilyRelationshipMapping]

		CREATE NONCLUSTERED INDEX [TEMP_FKIX_PlanFamilyRelationshipMapping_SourcePlanProductId] ON [dbo].[PlanFamilyRelationshipMapping]
		([SourcePlanProductId])

	IF EXISTS(SELECT * FROM sys.indexes WHERE object_id = object_id('dbo.PlanFamilyRelationshipMapping') AND NAME ='TEMP_FKIX_PlanFamilyRelationshipMapping_DestinationPlanProductId')
		DROP INDEX [TEMP_FKIX_PlanFamilyRelationshipMapping_DestinationPlanProductId] ON [dbo].[PlanFamilyRelationshipMapping]

		CREATE NONCLUSTERED INDEX [TEMP_FKIX_PlanFamilyRelationshipMapping_DestinationPlanProductId] ON [dbo].[PlanFamilyRelationshipMapping]
		([SourcePlanProductId])


	----------

	DECLARE @dynsql nvarchar(max)  

	IF OBJECT_ID(N'tempdb..#IntegrationAccountList') IS NOT NULL
	BEGIN
		 DROP TABLE #IntegrationAccountList
	END
	CREATE TABLE #IntegrationAccountList
	(AccountId bigint PRIMARY KEY CLUSTERED)

	if  @AccountId = 0
		   Insert into #IntegrationAccountList (AccountId)
		   SELECT TOP 30000 AccountId from
		   (
				  Select Id as AccountId
				  from Account
				  where CompanyName ='Fusebill Integration Test'
				  and ContactEmail like '%noreply@fusebillintegrationtest.com%'
				  AND CreatedTimestamp < @OlderThanDate
		   )data
		   order by AccountId 
	Else
		   Insert into #IntegrationAccountList (AccountId)
		   Select @AccountId 


	--- DISABLE FEATURE CONFIGURATIONS
	UPDATE a SET
		[SalesforceEnabled] = 0
		, [SalesforceBulkSyncEnabled] = 0
		, [NetsuiteEnabled] = 0
		, [TaxOptionId] = 1
		, [WebhooksEnabled] = 0
		, [ProjectedInvoiceEnabled] = 0
		, [QuickBooksEnabled] = 0
		, [PreventCreditCardValidation] = 1
		, [SalesforceCatalogSync] = 0
		, [HubSpotConfigured] = 0
	FROM AccountFeatureConfiguration a
	INNER JOIN #IntegrationAccountList i ON a.Id = i.AccountId

	-- EXCLUDE FROM BILLING
	INSERT INTO [dbo].[AccountsExcludedFromBilling] (
		[AccountId]
		, [CreatedTimestamp]
		, [Note]
	)
	SELECT AccountId, GETUTCDATE(), 'Excluding integration test'
	FROM #IntegrationAccountList

	INSERT INTO [dbo].[AccountsExcludedFromEarning] (
		[AccountId]
		, [CreatedTimestamp]
		, [Note]
	)
	SELECT AccountId, GETUTCDATE(), 'Excluding integration test'
	FROM #IntegrationAccountList

	-- EXCLUDE FROM EARNING

		DELETE
			targetTable
		FROM [dbo].[NetsuiteErrorLog] targetTable
			INNER JOIN #IntegrationAccountList i
				ON targetTable.AccountId = i.AccountId

		DELETE
			targetTable
		FROM [dbo].[AccountBillingHierarchyConfiguration] targetTable
			INNER JOIN #IntegrationAccountList i
				ON targetTable.Id = i.AccountId

		DELETE
			targetTable
		FROM [dbo].[AccountTxtSchedule] targetTable
			INNER JOIN #IntegrationAccountList i
				ON targetTable.AccountId = i.AccountId

		DELETE
			targetTable
		FROM [dbo].[AccountTxtTemplate] targetTable
			INNER JOIN #IntegrationAccountList i
				ON targetTable.AccountId = i.AccountId

		DELETE
			targetTable
		FROM [dbo].[HubSpotAuthenticationToken] targetTable
			INNER JOIN #IntegrationAccountList i
				ON targetTable.AccountId = i.AccountId

		DELETE
			targetTable
		FROM [dbo].[IntegrationIgnoredWarning] targetTable
			INNER JOIN #IntegrationAccountList i
				ON targetTable.AccountId = i.AccountId

		DELETE
			targetTable
		FROM [dbo].SalesforceSyncStatus targetTable
			INNER JOIN #IntegrationAccountList i
				ON targetTable.AccountId = i.AccountId
		
		DELETE
			targetTable
		FROM [dbo].[AccountQuickBooksOnlineCurrencyExchange] targetTable
			INNER JOIN #IntegrationAccountList i
				ON targetTable.AccountId = i.AccountId

		DELETE
			targetTable
		FROM [dbo].[AccountQuickBooksOnlineConfig] targetTable
			INNER JOIN #IntegrationAccountList i
				ON targetTable.Id = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   AccountHubspotCustomerInformationConfiguration targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   AccountHubSpotConfiguration targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.Id = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   AccountAvalaraNexus targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   AccountGeotabConfiguration targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.Id = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   ReportScheduleParameter targetTable
			   inner join ReportSchedule rs
				on rs.Id = targetTable.ReportScheduleId
			   inner join Report r
				on r.Id = rs.ReportId
			   inner join #IntegrationAccountList i
			   on r.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   ReportSchedule targetTable
			   inner join Report r
				on r.Id = targetTable.ReportId
			   inner join #IntegrationAccountList i
			   on r.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   Report targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   [dbo].[AccountResetLog] targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   [dbo].[AccountResetSummary] targetTable
			   inner join [dbo].[AccountReset] ar ON ar.Id = targetTable.AccountResetId
			   inner join #IntegrationAccountList i
			   on ar.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   [dbo].[AccountReset] targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   [dbo].[AccountQuickBooksOnlineCurrencyExchange] targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   [dbo].[QuickBooksLog] targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   [dbo].[AccountQuickBooksOnlineConfig] targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.Id = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   [dbo].[SalesforceOpportunityPurchase] targetTable
			   INNER JOIN [SalesforceOpportunity] so on targetTable.SalesforceOpportunityId = so.Id
			   inner join #IntegrationAccountList i
			   on so.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   [dbo].[SalesforceOpportunity] targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   [dbo].[AccountSalesforceOpportunityDefaultFieldMapping] targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   [dbo].[AccountSalesforceOpportunityFieldMapping] targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   [dbo].[FusebillPreviewLogin] targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   [dbo].[AvalaraLog] targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   Migration targetTable
			   inner join PlanFamilyRelationship pfr ON pfr.Id = targetTable.RelationshipId
			   inner join PlanFamily pf ON pf.Id = pfr.PlanFamilyId
			   inner join #IntegrationAccountList i
			   on pf.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   DraftSubscriptionProductCharge  targetTable
			   inner join ScheduledMigration sm
			   on targetTable.ScheduledMigrationId = sm.Id
			   inner join Customer c
			   on sm.CustomerId = c.id
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
				InstantPaymentNotification targetTable
				inner join Customer c on c.Id = targetTable.CustomerId
				inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
				CustomerSmsNumber targetTable
				inner join Customer c on c.Id = targetTable.CustomerId
				inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
				PaymentMethodValidationConcurrencyLock targetTable
				inner join Customer c on c.Id = targetTable.Id
				inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   ScheduledMigration targetTable
			   inner join PlanFamilyRelationship pfr ON pfr.Id = targetTable.[PlanFamilyRelationshipId]
			   inner join PlanFamily pf ON pf.Id = pfr.PlanFamilyId
			   inner join #IntegrationAccountList i
			   on pf.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   PlanFamilyRelationShipMapping  targetTable
			   inner join PlanFamilyRelationship pfr ON pfr.Id = targetTable.PlanFamilyRelationshipId
			   inner join PlanFamily pf ON pf.Id = pfr.PlanFamilyId
			   inner join #IntegrationAccountList i
			   on pf.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
				HostedPagePlanFamilyRelationship targetTable
				inner join PlanFamilyRelationShip  pfr ON pfr.Id = targetTable.[PlanFamilyRelationshipId]
			   inner join PlanFamily pf ON pf.Id = pfr.PlanFamilyId
			   inner join #IntegrationAccountList i
			   on pf.AccountId = i.AccountId

		delete 
				targetTable 
		from 
				[dbo].[HostedPageManagedSectionPurchase] targetTable
				inner join Product p on p.Id = targetTable.ProductId
				inner join #IntegrationAccountList i
				on p.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
				[dbo].[HostedPageManagedSectionMigration] targetTable
				inner join PlanFamilyRelationShip  pfr ON pfr.Id = targetTable.[PlanFamilyRelationshipId]
			   inner join PlanFamily pf ON pf.Id = pfr.PlanFamilyId
			   inner join #IntegrationAccountList i
			   on pf.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   PlanFamilyRelationShip  targetTable
			   inner join PlanFamily pf ON pf.Id = targetTable.PlanFamilyId
			   inner join #IntegrationAccountList i
			   on pf.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   PlanFamilyPlan  targetTable
			   inner join PlanFamily pf ON pf.Id = targetTable.PlanFamilyId
			   inner join #IntegrationAccountList i
			   on pf.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   PlanFamily  targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   AuditTrail  targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   ReportExport  targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   CreditAllocation  targetTable
			   inner join Invoice inv
			   on targetTable.InvoiceId = inv.Id
			   inner join #IntegrationAccountList i
			   on inv.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   DraftSubscriptionProductCharge  targetTable
			   inner join DraftCharge dc
			   on targetTable.Id = dc.Id
			   inner join Customer c
			   on dc.CustomerId = c.id
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   DraftChargeTier  targetTable
			   inner join DraftCharge dc
			   on targetTable.DraftChargeId = dc.Id
			   inner join Customer c
			   on dc.CustomerId = c.id
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   SubscriptionProductDiscount targetTable
			   inner join
			   CouponCode  cc
			   on targetTable.CouponCodeId = cc.Id 
			   inner join Coupon cou
			   on cc.CouponId  = cou.Id
			   inner join #IntegrationAccountList i
			   on cou.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   SubscriptionCouponCode targetTable
			   inner join
			   CouponCode  cc
			   on targetTable.CouponCodeId = cc.Id 
			   inner join Coupon cou
			   on cc.CouponId  = cou.Id
			   inner join #IntegrationAccountList i
			   on cou.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   [dbo].[CustomerEmailLogAttachment] targetTable
			   inner join CustomerEmailLog cel
			   on targetTable.[CustomerEmailLogId] = cel.id
			   inner join Customer c on cel.CustomerId = c.Id
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   CustomerEmailLogDraftInvoice   targetTable
			   inner join draftInvoice inv
			   on targetTable.draftInvoiceId = inv.Id
			   inner join Customer c on inv.CustomerId = c.Id
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   CustomerEmailLogInvoice   targetTable
			   inner join Invoice inv
			   on targetTable.InvoiceId = inv.Id
			   inner join #IntegrationAccountList i
			   on inv.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   [RolePermission]    targetTable
			   inner join [Role] r on targetTable.RoleId = r.Id
			   inner join #IntegrationAccountList i
			   on r.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   AccountUserRole    targetTable
			   inner join AccountUser au
			   on targetTable.AccountUserId  = au.Id 
			   inner join #IntegrationAccountList i
			   on au.AccountId  = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   [Role]   targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   AccountAutomatedHistoryFailure   targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.AccountId = i.AccountId


		DELETE 
			   targetTable
		FROM 
			   AccountSalesTrackingCodeConfiguration   targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.Id = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   AccountDisplaySetting   targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.AccountId = i.AccountId
	
		DELETE 
			   targetTable
		FROM 
			   DebitAllocation   targetTable
			   inner join Invoice inv
			   on targetTable.InvoiceId = inv.Id
			   inner join #IntegrationAccountList i
			   on inv.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   OpeningBalanceAllocation targetTable
			   inner join OpeningBalance p
			   on targetTable.OpeningBalanceId  = p.id
			   inner join [Transaction] t
			   on p.Id = t.id
			   inner join #IntegrationAccountList i
			   on t.AccountId = i.AccountId
		
		DELETE 
			   targetTable
		FROM 
			   CustomerIntegration targetTable
			   inner join Customer c on targetTable.CustomerId = c.id
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
				CustomerTxtControl targetTable
				inner join Customer c on c.Id = targetTable.CustomerId
				inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
				CustomerTxtPreference targetTable
				inner join Customer c on c.Id = targetTable.CustomerId
				inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
				CustomerTextLog targetTable
				inner join Customer c on c.Id = targetTable.CustomerId
				inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   CustomerStartingData targetTable
			   inner join Customer c
			   on targetTable.Id = c.id
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   Reporting.FactSubscriptionProduct  targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.AccountId = i.AccountId 

		DELETE 
			   targetTable
		FROM 
			   WriteOff targetTable
			   inner join [Transaction] t
			   on targetTable.Id = t.id
			   inner join #IntegrationAccountList i
			   on t.AccountId = i.AccountId

		DELETE
			   targettable
		FROM
			   SelfServicePortalToken targettable
			   inner join Customer c 
			   on targettable.CustomerId = c.Id
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE
			   targettable
		FROM
				CustomerEmailLogBillingStatement targettable
				inner join 
			   CustomerEmailLog  cel
			   on targettable.CustomerEmailLogId = cel.id 
			   inner join Customer c 
			   on cel.CustomerId = c.Id
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   SendGridEvents  targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.AccountId  = i.AccountId

		DELETE
			   targettable
		FROM
			   CustomerEmailLog  targettable
			   inner join Customer c 
			   on targettable.CustomerId = c.Id
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE
			   targettable
		FROM
			   AccountInvoicePreferenceDisplayField  targettable
			   inner join #IntegrationAccountList i
			   on targettable.Id = i.AccountId

		DELETE
			   targettable
		FROM
			   AvalaraLog targettable
			   inner join Customer c 
			   on targettable.CustomerId = c.Id
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   CustomerBillingPeriodConfiguration  targetTable
			   inner join Customer c
			   on targetTable.CustomerBillingSettingId  = c.id
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   OpeningBalance targetTable
			   inner join [Transaction] t
			   on targetTable.Id = t.id
			   inner join #IntegrationAccountList i
			   on t.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   CustomerInvoiceSetting  targetTable
			   inner join Customer c
			   on targetTable.Id = c.id
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   PaymentNote targetTable
			   inner join Payment p
			   on targetTable.PaymentId = p.id
			   inner join [Transaction] t
			   on p.Id = t.id
			   inner join #IntegrationAccountList i
			   on t.AccountId = i.AccountId

		DELETE
			   targetTable
		FROM 
			   VoidReverseDiscount  targetTable
			   inner join [Transaction] t
			   on targetTable.Id = t.id 
			   inner join #IntegrationAccountList i
			   on t.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   reversediscount targetTable
			   inner join Discount d
			   on targetTable.OriginalDiscountId = d.id
			   inner join [Transaction] t
			   on d.Id = t.id
			   inner join #IntegrationAccountList i
			   on t.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   EarningDiscount targetTable
			   inner join Discount d
			   on targetTable.DiscountId = d.id
			   inner join [Transaction] t
			   on d.Id = t.id
			   inner join #IntegrationAccountList i
			   on t.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   Discount targetTable
			   inner join [Transaction] t
			   on targetTable.Id = t.id
			   inner join #IntegrationAccountList i
			   on t.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   EarningOpeningDeferredRevenue targetTable
			   inner join [Transaction] t
			   on targetTable.Id = t.id
			   inner join #IntegrationAccountList i
			   on t.AccountId = i.AccountId   
	   
		DELETE 
			   targetTable
		FROM 
			   OpeningDeferredRevenue targetTable
			   inner join [Transaction] t
			   on targetTable.Id = t.id
			  inner join #IntegrationAccountList i
			   on t.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   RefundNote targetTable
			   inner join Refund r
			   on targetTable.RefundId  = r.id
			   inner join [Transaction] t
			   on r.Id = t.id
			   inner join #IntegrationAccountList i
			   on t.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   Refund targetTable
			   inner join [Transaction] t
			   on targetTable.Id = t.id
			  inner join #IntegrationAccountList i
			   on t.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   Payment targetTable
			   inner join [Transaction] t
			   on targetTable.Id = t.id
			  inner join #IntegrationAccountList i
			   on t.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   AccountBillingPeriodConfiguration  targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.AccountBillingPreferenceId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   CollectionNote  targetTable
			   inner join Customer c
			   on targetTable.CustomerId = c.id
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE --after payment
			   targetTable
		FROM 
			   PaymentActivityJournal  targetTable
			   inner join Customer c
			   on targetTable.CustomerId = c.id
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   CustomerNote targetTable
			   inner join Customer c
			   on targetTable.CustomerId = c.id
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE
			   targetTable
		FROM 
			   VoidReverseTax  targetTable
			   inner join [Transaction] t
			   on targetTable.Id = t.id 
			   inner join #IntegrationAccountList i
			   on t.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   ReverseTax targetTable
			   inner join Tax t 
			   on targetTable.OriginalTaxId = t.Id 
			   inner join TaxRule tr
			   on t.TaxRuleId = tr.id
			   inner join #IntegrationAccountList i
			   on tr.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   Tax targetTable
			   inner join TaxRule tr
			   on targetTable.TaxRuleId = tr.id
			   inner join #IntegrationAccountList i
			   on tr.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   CustomerBillingStatementSetting targetTable
			   inner join Customer c
			   on targetTable.Id = c.Id 
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   BillingStatement targetTable
			   inner join Customer c
			   on targetTable.CustomerId = c.Id 
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   DraftTax targetTable
			   inner join TaxRule tr
			   on targetTable.TaxRuleId = tr.id
			   inner join #IntegrationAccountList i
			   on tr.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   AccountBillingStatementPreference targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.Id = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   AccountAccountingPreference targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.Id = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   AvalaraConfiguration targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.Id = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   AvalaraLog targetTable
			   inner join #IntegrationAccountList i
		   on targetTable.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   TaxRuleProductExemption targetTable
			   inner join TaxRule tr
			   on targetTable.TaxRuleId = tr.id
			   inner join #IntegrationAccountList i
			   on tr.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   TaxRule targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.AccountId = i.AccountId

		DELETE
			   targetTable
		FROM 
			   ChargeTier  targetTable
			   inner join Charge ch
			   on targetTable.ChargeId = ch.id
			   inner join [Transaction] t
			   on ch.Id = t.id 
			   inner join #IntegrationAccountList i
			   on t.AccountId = i.AccountId

		DELETE
			   targetTable
		FROM 
			   ChargeLastEarning  targetTable
			   inner join Charge ch
			   on targetTable.Id = ch.id
			   inner join [Transaction] t
			   on ch.Id = t.id 
			  inner join #IntegrationAccountList i
			   on t.AccountId = i.AccountId

		DELETE
			   targetTable
		FROM 
			   EarningDiscountSchedule targetTable
			   inner join Charge ch
			   on targetTable.ChargeId = ch.id
			   inner join [Transaction] t
			   on ch.Id = t.id 
			  inner join #IntegrationAccountList i
			   on t.AccountId = i.AccountId

		DELETE
			   targetTable
		FROM 
			   EarningSchedule targetTable
			   inner join Charge ch
			   on targetTable.ChargeId = ch.id
			   inner join [Transaction] t
			   on ch.Id = t.id 
			  inner join #IntegrationAccountList i
			   on t.AccountId = i.AccountId

		DELETE
			   targetTable
		FROM 
			   Earning targetTable
			   inner join Charge ch
			   on targetTable.ChargeId = ch.id
			   inner join [Transaction] t
			   on ch.Id = t.id 
			  inner join #IntegrationAccountList i
			   on t.AccountId = i.AccountId

		DELETE
			   targetTable
		FROM 

			   debit targetTable
			   inner join Credit cr
			   on targetTable.OriginalCreditId = cr.id 
			   inner join [Transaction] t
			   on cr.Id = t.Id
			  inner join #IntegrationAccountList i
			   on t.AccountId = i.AccountId

		DELETE
			   targetTable
		FROM 
			   Credit targetTable
			   inner join [Transaction] t
			   on targetTable.id = t.id 
			   inner join #IntegrationAccountList i
			   on t.AccountId = i.AccountId

		DELETE
			   targetTable
		FROM 
			   SubscriptionProductActivityJournalCharge  targetTable
			   inner join Charge ch
			   on targetTable.ChargeId = ch.Id
			   inner join [Transaction] t
			   on ch.id = t.id 
			  inner join #IntegrationAccountList i
			   on t.AccountId = i.AccountId

		DELETE
			   targetTable
		FROM 
			   SubscriptionProductActivityJournalDraftCharge  targetTable
			   inner join DraftCharge dch
			   on targetTable.DraftChargeId = dch.Id
			   inner join Customer c
			   on dch.CustomerId = c.id
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE
			   targetTable
		FROM 
			   SubscriptionProductCustomField   targetTable
			   inner join SubscriptionProduct  sp
			   on targetTable.SubscriptionProductId = sp.id
			   inner join Subscription s
			   on sp.SubscriptionId = s.Id 
			   inner join Customer c
			   on s.CustomerId = c.id
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   SubscriptionProductItem  targetTable
			   inner join SubscriptionProduct   sp
			   on targetTable.SubscriptionProductId = sp.Id 
			   inner join Subscription s
			   on sp.SubscriptionId = s.Id
			   inner join Customer c
			   on s.CustomerId = c.Id 
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE
			   targetTable
		FROM 
			   SubscriptionProductPriceUplift   targetTable
			   inner join SubscriptionProduct  sp
			   on targetTable.SubscriptionProductId = sp.id
			   inner join Subscription s
			   on sp.SubscriptionId = s.Id 
			   inner join Customer c
			   on s.CustomerId = c.id
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE
			   targetTable
		FROM 
			   SubscriptionProductActivityJournal  targetTable
			   inner join SubscriptionProduct  sp
			   on targetTable.SubscriptionProductId = sp.id
			   inner join Subscription s
			   on sp.SubscriptionId = s.Id 
			   inner join Customer c
			   on s.CustomerId = c.id
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId		

		DELETE
			   targetTable
		FROM 
			   VoidReverseCharge  targetTable
			   inner join [Transaction] t
			   on targetTable.Id = t.id 
			   inner join #IntegrationAccountList i
			   on t.AccountId = i.AccountId

		DELETE
			   targetTable
		FROM 
			   ReverseEarning  targetTable
			   inner join [Transaction] t
			   on targetTable.Id = t.id 
			   INNER join #IntegrationAccountList i
			   on t.AccountId = i.AccountId

		DELETE
			   targetTable
		FROM 
			   ReverseCharge  targetTable
			   inner join [Transaction] t
			   on targetTable.Id = t.id 
			   inner join #IntegrationAccountList i
			   on t.AccountId = i.AccountId

		DELETE
			   targetTable
		FROM 
			   ChargeProductItem  targetTable
			   inner join Charge dc
			   on targetTable.ChargeId = dc.Id
			   inner join Invoice  di
			   on dc.InvoiceId = di.id
			   inner join Customer c
			   on di.CustomerId = c.id
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE
			   targetTable
		FROM 
			   PurchaseCharge targetTable
			   inner join [Transaction] t
			   on targetTable.Id = t.id 
			   inner join #IntegrationAccountList i
			   on t.AccountId = i.AccountId

		DELETE
			   targetTable
		FROM 
			   PurchaseCustomField targetTable
			   inner join Purchase pu
			   on targetTable.PurchaseId = pu.Id
			   inner join Customer c
			   on pu.CustomerId = c.id
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE
			   targetTable
		FROM 
			   PurchasePriceRange targetTable
			   inner join Purchase pu
			   on targetTable.PurchaseId = pu.Id
			   inner join Customer c
			   on pu.CustomerId = c.id
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE
			   targetTable
		FROM 
			   DraftPurchaseCharge  targetTable
			   inner join Purchase pu
			   on targetTable.PurchaseId = pu.Id
			   inner join Customer c
			   on pu.CustomerId = c.id
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE
			   targetTable
		FROM 
			   PurchaseDiscount  targetTable
			   inner join Purchase pu
			   on targetTable.PurchaseId = pu.Id
			   inner join Customer c
			   on pu.CustomerId = c.id
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE
			   targetTable
		FROM 
			   PurchaseProductItem   targetTable
			   inner join Purchase pu
			   on targetTable.PurchaseId = pu.Id
			   inner join Customer c
			   on pu.CustomerId = c.id
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE
			   targetTable
		FROM 
			   PurchaseCouponCode   targetTable
			   inner join Purchase pu
			   on targetTable.PurchaseId = pu.Id
			   inner join Customer c
			   on pu.CustomerId = c.id
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId
			   --"dbo.PurchaseCouponCode", 

		DELETE
			   targetTable
		FROM 
			   PurchaseEarningDiscountSchedule   targetTable
			   inner join PurchaseEarningSchedule pes ON pes.id = targetTable.PurchaseEarningScheduleId
			   inner join Purchase pu
			   on pes.PurchaseId = pu.Id
			   inner join Customer c
			   on pu.CustomerId = c.id
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE
			   targetTable
		FROM 
			   PurchaseEarningSchedule   targetTable
			   inner join Purchase pu
			   on targetTable.PurchaseId = pu.Id
			   inner join Customer c
			   on pu.CustomerId = c.id
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE
			   targetTable
		FROM 
			   Purchase targetTable

			   inner join Customer c
			   on targetTable.CustomerId = c.id
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE
			   targetTable
		FROM 
			   AccountUploadRecord targetTable
			   inner join AccountUpload au
			   on targetTable.AccountUploadId = au.id
			   inner join #IntegrationAccountList i
			   on au.AccountId = i.AccountId

		DELETE
			   targetTable
		FROM 
			   AccountUpload targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.AccountId = i.AccountId

		DELETE
			   targetTable
		FROM 
			   SubscriptionProductCharge targetTable
			   inner join [Transaction] t
			   on targetTable.Id = t.id 
			   inner join #IntegrationAccountList i
			   on t.AccountId = i.AccountId

		DELETE
			   targetTable
		FROM 
			   Charge targetTable
			   inner join [Transaction] t
			   on targetTable.Id = t.id 
			   inner join #IntegrationAccountList i
			   on t.AccountId = i.AccountId
	
		DELETE 
			   targetTable
		FROM 
			   AccountApiKey    targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.AccountId = i.AccountId


		DELETE
			   targetTable
		FROM 
			   ChargeGroup targetTable
			   inner join Invoice inv
			   on targetTable.InvoiceId = inv.id 
			   inner join #IntegrationAccountList i
			   on inv.AccountId = i.AccountId

		DELETE
			   targetTable
		FROM 
			   DraftDiscount targetTable
			   inner join    draftCharge dc
			   on targetTable.DraftChargeId = dc.Id
			   inner join Customer c
			   on dc.CustomerId = c.id
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE
			   targetTable
		FROM 
			   DraftTax targetTable
			   inner join    draftCharge dc
			   on targetTable.DraftChargeId = dc.Id
			   inner join Customer c
			   on dc.CustomerId = c.id
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId


		DELETE
			   targetTable
		FROM 
			   AccountNetsuiteFieldMapping targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.AccountId = i.AccountId

		DELETE
			   targetTable
		FROM 
			   AccountNetsuiteCreditItemMapping targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.AccountNetsuiteConfigurationId = i.AccountId

		DELETE
			   targetTable
		FROM 
			   [AccountNetsuiteConfiguration] targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.Id = i.AccountId

		DELETE
			   targetTable
		FROM 
			   DraftChargeProductItem  targetTable
			   inner join DraftCharge dc
			   on targetTable.DraftChargeId = dc.Id
			   inner join Customer c
			   on dc.CustomerId = c.id
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId
			   /**/
		DELETE
			   targetTable
		FROM 
			   draftCharge targetTable
			   inner join Customer c
			   on targetTable.CustomerId = c.id
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE
			   targetTable
		FROM 
			   draftCharge targetTable
			   inner join DraftInvoice dc
			   on targetTable.DraftInvoiceId  = dc.Id 
			   inner join Customer c on dc.CustomerId = c.Id
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId
	
		DELETE 
			   targetTable
		FROM 
			   CreditCardExpiryActivity targetTable
			   inner join
			   CreditCard cc
			   on targetTable.creditcardid = cc.Id
			   inner join 
			   PaymentMethod  pm
			   on cc.Id = pm.Id
			   inner join Customer c
			   on pm.CustomerId = c.Id 
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId
	
		DELETE 
			   targetTable
		FROM 
			   PaymentMethodSharing targetTable
			   inner join 
			   PaymentMethod  pm
			   on targetTable.PaymentMethodId = pm.Id
			   inner join Customer c
			   on pm.CustomerId = c.Id 
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   CustomerEmailControl   targetTable
			   inner join Customer c
			   on targetTable.CustomerId = c.Id 
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   CustomerEmailLog   targetTable
			   inner join Customer c
			   on targetTable.CustomerId = c.Id 
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   CustomerAccountStatusJournal   targetTable
			   inner join Customer c
			   on targetTable.CustomerId = c.Id 
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   CustomerStatusJournal   targetTable
			   inner join Customer c
			   on targetTable.CustomerId = c.Id 
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   DraftPaymentSchedule targetTable
			   inner join DraftInvoice DI
			   on targetTable.DraftInvoiceId = DI.id
			   inner join Customer c
			   on DI.CustomerId = c.Id 
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   ProjectedInvoice  targetTable
			   inner join DraftInvoice bp
			   on targetTable.ProjectedInvoiceId = bp.id 
			   inner join Customer c
			   on targetTable.CustomerId = c.Id 
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   DraftInvoice  targetTable
			   inner join Customer c
			   on targetTable.CustomerId = c.Id 
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   DraftInvoice  targetTable
			   inner join Customer c
			   on targetTable.CustomerId = c.Id 
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   CustomerCredential   targetTable
			   inner join Customer c
			   on targetTable.Id = c.Id 
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   CreditNote targetTable
			   inner join Invoice inv
			   on targetTable.InvoiceId = inv.Id
			   inner join #IntegrationAccountList i
			   on inv.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   [CreditNoteGroup] targetTable
			   inner join Invoice inv
			   on targetTable.InvoiceId = inv.Id
			   inner join #IntegrationAccountList i
			   on inv.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   InvoiceCustomer targetTable
			   inner join Invoice inv
			   on targetTable.InvoiceId = inv.id 
			   inner join #IntegrationAccountList i
			   on inv.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   InvoiceAddress targetTable
			   inner join Invoice inv
			   on targetTable.InvoiceId = inv.id 
			   inner join #IntegrationAccountList i
			   on inv.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   InvoiceAddressAdditional targetTable
			   inner join InvoiceCustomerAdditional ica
			   on targetTable.InvoiceCustomerAdditionalId = ica.Id
			   inner join Invoice inv ON inv.Id = ica.InvoiceId
			   inner join #IntegrationAccountList i
			   on inv.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   InvoiceCustomerAdditional targetTable
			   inner join Invoice inv ON inv.Id = targetTable.InvoiceId
			   inner join #IntegrationAccountList i
			   on inv.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   Dispute targetTable
			   inner join Invoice inv
			   on targetTable.InvoiceId = inv.id 
			   inner join #IntegrationAccountList i
			   on inv.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   PaymentScheduleJournal  targetTable
			   inner join PaymentSchedule ps
			   on targetTable.PaymentScheduleId = ps.id
			   inner join Invoice inv
			   on ps.InvoiceId = inv.id 
			   inner join #IntegrationAccountList i
			   on inv.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   CollectionScheduleActivity   targetTable
			   inner join Customer c
			   on targetTable.CustomerId = c.Id
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId


		DELETE 
			   targetTable
		FROM 
			   PaymentSchedule  targetTable
			   inner join Invoice inv
			   on targetTable.InvoiceId = inv.id 
			   inner join #IntegrationAccountList i
			   on inv.AccountId = i.AccountId		

		DELETE 
			   targetTable
		FROM 
			   InvoiceJournal targetTable
			   inner join Invoice inv
			   on targetTable.InvoiceId = inv.id 
			   inner join #IntegrationAccountList i
			   on inv.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   InvoiceRevision targetTable
			   inner join Invoice inv
			   on targetTable.InvoiceId = inv.id 
			   inner join #IntegrationAccountList i
			   on inv.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   Invoice targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   InvoiceSignature targetTable			   
			   inner join #IntegrationAccountList i
			   on targetTable.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   HostedPageRegistration  targetTable
			   inner join HostedPage hp
			   on targetTable.Id = hp.id 
			   inner join #IntegrationAccountList i
			   on hp.AccountId = i.AccountId


		DELETE 
			   targetTable
		FROM 
			   [HostedPageManagedOfferingAvailableCountry]  targetTable
			   inner join [HostedPageManagedOffering] hpm
			   on targetTable.HostedPageManagedOfferingId = hpm.id 
			   inner join HostedPage hp
			   on hpm.HostedPageId = hp.id 
			   inner join #IntegrationAccountList i
			   on hp.AccountId = i.AccountId
			   

		DELETE 
			   targetTable
		FROM 
			   [HostedPageManagedOfferingAvailableSalesTrackingCode]  targetTable
			   inner join [HostedPageManagedOffering] hpm
			   on targetTable.HostedPageManagedOfferingId = hpm.id 
			   inner join HostedPage hp
			   on hpm.HostedPageId = hp.id 
			   inner join #IntegrationAccountList i
			   on hp.AccountId = i.AccountId
			   

		DELETE 
			   targetTable
		FROM 
			   [HostedPageManagedOfferingProduct]  targetTable
			   inner join [HostedPageManagedOffering] hpm
			   on targetTable.HostedPageManagedOfferingId = hpm.id 
			   inner join HostedPage hp
			   on hpm.HostedPageId = hp.id 
			   inner join #IntegrationAccountList i
			   on hp.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   [HostedPageManagedOfferingPreviewPanel]  targetTable
			   inner join [HostedPageManagedOffering] hpm
			   on targetTable.Id = hpm.id 
			   inner join HostedPage hp
			   on hpm.HostedPageId = hp.id 
			   inner join #IntegrationAccountList i
			   on hp.AccountId = i.AccountId


		DELETE 
			   targetTable
		FROM 
			   [HostedPageManagedOfferingPlanProduct]  targetTable
			   inner join [HostedPageManagedOfferingPlan] hpmop 
			   on hpmop.Id = targetTable.HostedPageManagedOfferingPlanId
			   inner join [HostedPageManagedOffering] hpm
			   on hpmop.HostedPageManagedOfferingId = hpm.id 
			   inner join HostedPage hp
			   on hpm.HostedPageId = hp.id 
			   inner join #IntegrationAccountList i
			   on hp.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   [HostedPageManagedOfferingPlanFrequency]  targetTable
			   INNER JOIN [HostedPageManagedOfferingPlan] hpmop 
			   ON hpmop.Id = targetTable.HostedPageManagedOfferingPlanId
			   INNER JOIN [HostedPageManagedOffering] hpm
			   ON hpmop.HostedPageManagedOfferingId = hpm.id 
			   INNER JOIN HostedPage hp
			   ON hpm.HostedPageId = hp.id 
			   INNER JOIN #IntegrationAccountList i
			   ON hp.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   [HostedPageManagedOfferingPlan]  targetTable
			   inner join [HostedPageManagedOffering] hpm
			   on targetTable.HostedPageManagedOfferingId = hpm.id 
			   inner join HostedPage hp
			   on hpm.HostedPageId = hp.id 
			   inner join #IntegrationAccountList i
			   on hp.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   [HostedPageManagedOfferingCustomerInformation]  targetTable
			   inner join [HostedPageManagedOffering] hpm
			   on targetTable.HostedPageManagedOfferingId = hpm.id 
			   inner join HostedPage hp
			   on hpm.HostedPageId = hp.id 
			   inner join #IntegrationAccountList i
			   on hp.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   [HostedPageManagedOfferingPaymentMethod]  targetTable
			   inner join [HostedPageManagedOffering] hpm
			   on targetTable.HostedPageManagedOfferingId = hpm.id 
			   inner join HostedPage hp
			   on hpm.HostedPageId = hp.id 
			   inner join #IntegrationAccountList i
			   on hp.AccountId = i.AccountId


		DELETE 
			   targetTable
		FROM 
			   [HostedPageManagedOfferingLabel]  targetTable
			   inner join [HostedPageManagedOffering] hpm
			   on targetTable.Id = hpm.id 
			   inner join HostedPage hp
			   on hpm.HostedPageId = hp.id 
			   inner join #IntegrationAccountList i
			   on hp.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   [HostedPageManagedCurrencyOfferingRelationship]  targetTable
			   inner join [HostedPageManagedSectionSubscription] hpmss
			   on hpmss.Id = targetTable.HostedPageManagedSectionSubscriptionId
			   inner join HostedPageManagedSelfServicePortal hpm
			   on hpmss.id = hpm.id 
			   inner join HostedPage hp
			   on hpm.HostedPageId = hp.id 
			   inner join #IntegrationAccountList i
			   on hp.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   [HostedPageManagedOfferingLoginConfiguration]  targetTable
			   inner join [HostedPageManagedOffering] hpm
			   on targetTable.Id = hpm.id 
			   inner join HostedPage hp
			   on hpm.HostedPageId = hp.id 
			   inner join #IntegrationAccountList i
			   on hp.AccountId = i.AccountId	

		DELETE 
			   targetTable
		FROM 
			   [HostedPageManagedOffering]  targetTable
			   inner join HostedPageManagedSelfServicePortal hpm
			   on targetTable.HostedPageManagedSelfServicePortalId = hpm.id 
			   inner join HostedPage hp
			   on hpm.HostedPageId = hp.id 
			   inner join #IntegrationAccountList i
			   on hp.AccountId = i.AccountId


		DELETE 
			   targetTable
		FROM 
			   [dbo].[HostedPageManagedSectionMigration]  targetTable
			   inner join HostedPageManagedSelfServicePortal hpm
			   on targetTable.Id = hpm.id 
			   inner join HostedPage hp
			   on hpm.HostedPageId = hp.id 
			   inner join #IntegrationAccountList i
			   on hp.AccountId = i.AccountId


		DELETE 
			   targetTable
		FROM 
			   [dbo].[HostedPageManagedSectionNavigation]  targetTable
			   inner join HostedPageManagedSelfServicePortal hpm
			   on targetTable.Id = hpm.id 
			   inner join HostedPage hp
			   on hpm.HostedPageId = hp.id 
			   inner join #IntegrationAccountList i
			   on hp.AccountId = i.AccountId


		DELETE 
			   targetTable
		FROM 
			   HostedPageManagedSectionHome  targetTable
			   inner join HostedPageManagedSelfServicePortal hpm
			   on targetTable.id = hpm.id 
			   inner join HostedPage hp
			   on hpm.HostedPageId = hp.id 
			   inner join #IntegrationAccountList i
			   on hp.AccountId = i.AccountId
	   
		DELETE 
			   targetTable
		FROM 
			   HostedPageManagedSectionSubscription  targetTable
			   inner join HostedPageManagedSelfServicePortal hpm
			   on targetTable.id = hpm.id 
			   inner join HostedPage hp
			   on hpm.HostedPageId = hp.id 
			   inner join #IntegrationAccountList i
			   on hp.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   HostedPageManagedSectionPaymentMethod  targetTable
			   inner join HostedPageManagedSelfServicePortal hpm
			   on targetTable.id = hpm.id 
			   inner join HostedPage hp
			   on hpm.HostedPageId = hp.id 
			   inner join #IntegrationAccountList i
			   on hp.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   HostedPageManagedSectionInvoice  targetTable
			   inner join HostedPageManagedSelfServicePortal hpm
			   on targetTable.id = hpm.id 
			   inner join HostedPage hp
			   on hpm.HostedPageId = hp.id 
			   inner join #IntegrationAccountList i
			   on hp.AccountId = i.AccountId
	   
		DELETE 
			   targetTable
		FROM 
			   HostedPageManagedSelfServicePortal  targetTable
			   inner join HostedPage hp
			   on targetTable.HostedPageId = hp.id 
			   inner join #IntegrationAccountList i
			   on hp.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   HostedPageSelfServicePortal  targetTable
			   inner join HostedPage hp
			   on targetTable.Id = hp.id 
			   inner join #IntegrationAccountList i
			   on hp.AccountId = i.AccountId

		DELETE
				targetTable
		FROM
				HostedPageManagedQuote targetTable
				inner join HostedPage hp
				on targetTable.HostedPageId = hp.Id
				inner join #IntegrationAccountList i
				on hp.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   HostedPage targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   SubscriptionOverride  targetTable
			   inner join Subscription s
			   on targetTable.Id = s.Id
			   inner join Customer c
			   on s.CustomerId = c.Id 
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   SubscriptionProductDiscount targetTable
			   inner join SubscriptionProduct   sp
			   on targetTable.SubscriptionProductId  = sp.Id 
			   inner join Subscription s
			   on sp.SubscriptionId = s.Id
			   inner join Customer c
			   on s.CustomerId = c.Id 
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   SubscriptionProductJournal targetTable
			   inner join SubscriptionProduct   sp
			   on targetTable.SubscriptionProductId  = sp.Id 
			   inner join Subscription s
			   on sp.SubscriptionId = s.Id
			   inner join Customer c
			   on s.CustomerId = c.Id 
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   SubscriptionProductOverride targetTable
			   inner join SubscriptionProduct   sp
			   on targetTable.id = sp.Id 
			   inner join Subscription s
			   on sp.SubscriptionId = s.Id
			   inner join Customer c
			   on s.CustomerId = c.Id 
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   PriceRangeOverride targetTable
			   inner join PricingModelOverride pmo
			   on targetTable.PricingModelOverrideId = pmo.Id
			   inner join SubscriptionProduct   sp
			   on pmo.Id = sp.Id 
			   inner join Subscription s
			   on sp.SubscriptionId = s.Id
			   inner join Customer c
			   on s.CustomerId = c.Id 
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   PricingModelOverride targetTable
			   inner join SubscriptionProduct   sp
			   on targetTable.Id = sp.Id 
			   inner join Subscription s
			   on sp.SubscriptionId = s.Id
			   inner join Customer c
			   on s.CustomerId = c.Id 
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId
	
		DELETE 
			   targetTable
		FROM 
			   FusebillSupportLogin   targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.AccountId = i.AccountId

		DELETE 
				targetTable
		FROM 
			   SubscriptionCustomField targetTable
			   inner join
			   CustomField    cf
			   on targetTable.CustomFieldId = cf.Id
			   inner join #IntegrationAccountList i
			   on cf.AccountId  = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   SubscriptionProductPriceRange targetTable
			   inner join SubscriptionProduct   sp
			   on targetTable.SubscriptionProductId = sp.Id 
			   inner join Subscription s
			   on sp.SubscriptionId = s.Id
			   inner join Customer c
			   on s.CustomerId = c.Id 
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   SubscriptionProduct   targetTable
			   inner join Subscription s
			   on targetTable.SubscriptionId = s.Id
			   inner join Customer c
			   on s.CustomerId = c.Id 
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   Subscriptionstatusjournal targetTable
			   inner join Subscription s 
			   on targetTable.SubscriptionId = s.Id
			   inner join Customer c
			   on s.CustomerId = c.Id 
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   Subscription targetTable
			   inner join Customer c
			   on targetTable.CustomerId = c.Id 
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   [Transaction] targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   PlanProductPriceUplift targetTable
			   inner join OrderToCashCycle occ
			   on targetTable.PlanOrderToCashCycleId = occ.id
			   inner join PlanOrderToCashCycle pocc
			   on occ.id = pocc.Id 
			   inner join PlanProduct pp
			   on pocc.PlanProductId = pp.id
			   inner join PlanRevision pr
			   on pp.PlanRevisionId = pr.id
			   inner join [plan] p
			   on pr.PlanId = p.id
			   inner join #IntegrationAccountList i
			   on p.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   Price targetTable
			   Inner join QuantityRange qr
			   on targetTable.QuantityRangeId = qr.id
			   --inner join PricingModel pm
			   --on qr.PricingModelId = pm.id
			   inner join OrderToCashCycle occ
			   on qr.OrderToCashCycleId = occ.id
			   inner join PlanOrderToCashCycle pocc
			   on occ.id = pocc.Id 
			   inner join PlanProduct pp
			   on pocc.PlanProductId = pp.id
			   inner join PlanRevision pr
			   on pp.PlanRevisionId = pr.id
			   inner join [plan] p
			   on pr.PlanId = p.id
			   inner join #IntegrationAccountList i
			   on p.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   QuantityRange targetTable
			   --inner join PricingModel pm
			   --on targetTable.PricingModelId = pm.id
			   inner join OrderToCashCycle occ
			   on targetTable.OrderToCashCycleId = occ.id
			   inner join PlanOrderToCashCycle pocc
			   on occ.id = pocc.Id 
			   inner join PlanProduct pp
			   on pocc.PlanProductId = pp.id
			   inner join PlanRevision pr
			   on pp.PlanRevisionId = pr.id
			   inner join [plan] p
			   on pr.PlanId = p.id
			   inner join #IntegrationAccountList i
			   on p.AccountId = i.AccountId

		DELETE 
				targetTable
		FROM 
			   PlanProductFrequencyCustomField targetTable
			   inner join
			   CustomField    cf
			   on targetTable.CustomFieldId = cf.Id
			   inner join #IntegrationAccountList i
			   on cf.AccountId  = i.AccountId

	BEGIN TRAN;

		declare @OrdertoCashCycle table

		(
		Id bigint
		)
		DELETE 
			   targetTable
		Output deleted.Id into @OrdertoCashCycle
		FROM 
			   PlanOrderToCashCycle targetTable
			   inner join PlanFrequency  pp
			   on targetTable.PlanFrequencyId  = pp.id
			   inner join PlanRevision pr
			   on pp.PlanRevisionId = pr.id
			   inner join [plan] p
			   on pr.PlanId = p.id
			   inner join #IntegrationAccountList i
			   on p.AccountId = i.AccountId

		DELETE 
			targettable
		from OrderToCashCycle Targettable
		inner join @OrdertoCashCycle occ
		on Targettable.id = occ.id

	COMMIT TRAN;

	BEGIN TRAN;

		IF OBJECT_ID(N'tempdb..#PlanFrequencyKeys') IS NOT NULL
		BEGIN
			 DROP TABLE #PlanFrequencyKeys
		END

		CREATE TABLE #PlanFrequencyKeys (PlanFrequencyKey BIGINT PRIMARY KEY CLUSTERED)
		INSERT INTO #PlanFrequencyKeys
		SELECT targetTable.Id
		FROM 
			   PlanFrequencyKey targetTable
			   inner join PlanFrequency  pp
			   on targetTable.Id  = pp.PlanFrequencyUniqueId
			   inner join PlanRevision pr
			   on pp.PlanRevisionId = pr.id
			   inner join [plan] p
			   on pr.PlanId = p.id
			   inner join #IntegrationAccountList i
			   on p.AccountId = i.AccountId
		UNION
			--Based on deletion order, these records could be orphaned from PlanFrequencyKey, so check to add them in as well
			SELECT TargetTable.PlanFrequencyUniqueId
			FROM PlanFrequencyCouponCode targetTable
					inner join CouponCode  pp
					on targetTable.CouponCodeId  = pp.Id
					inner join #IntegrationAccountList i
					on pp.AccountId = i.AccountId
			--May need to pull in the plan frequencies for PlanFrequencyCustomFields at some point if we get into another odd state

		DELETE 
			   targetTable
		FROM 
			   PlanFrequency  targetTable
			   inner join PlanRevision pr
			   on targetTable.PlanRevisionId = pr.id
			   inner join [plan] p
			   on pr.PlanId = p.id
			   inner join #IntegrationAccountList i
			   on p.AccountId = i.AccountId

		DELETE 
				targetTable
		FROM 
			   PlanFrequencyCustomField targetTable
			   inner join #PlanFrequencyKeys ppk
			   on targetTable.PlanFrequencyUniqueId = ppk.PlanFrequencyKey

		DELETE 
				targetTable
		FROM 
			   PlanFrequencyCouponCode targetTable
			   inner join #PlanFrequencyKeys ppk
			   on targetTable.PlanFrequencyUniqueId = ppk.PlanFrequencyKey

		DELETE targetTable 
		from PlanFrequencyKey targetTable
		inner join #PlanFrequencyKeys ppk
		on targetTable.Id = ppk.PlanFrequencyKey

		DROP TABLE #PlanFrequencyKeys

	COMMIT TRAN;

		DELETE 
			   targetTable
		FROM 
			   CouponPlanProduct  targetTable
			   inner join CouponPlan  cp
			   on targetTable.CouponPlanId  = cp.id
			   inner join [plan] p
			   on cp.PlanId = p.id
			   inner join #IntegrationAccountList i
			   on p.AccountId = i.AccountId

	BEGIN TRAN;

		IF OBJECT_ID(N'tempdb..#PlanProductKeys') IS NOT NULL
		BEGIN
			 DROP TABLE #PlanProductKeys
		END

		CREATE TABLE #PlanProductKeys (PlanProductKey BIGINT PRIMARY KEY CLUSTERED)
		INSERT INTO #PlanProductKeys
		SELECT targetTable.Id 
		FROM 
			   PlanProductKey targetTable
			   inner join PlanProduct  pp
			   on targetTable.Id  = pp.PlanProductUniqueId
			   inner join product pr
			   on pp.ProductId = pr.id
			   inner join #IntegrationAccountList i
			   on pr.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   CouponPlanProduct  targetTable
			   inner join #PlanProductKeys pk
			   on targetTable.planproductkey  = pk.PlanProductKey

		DELETE 
			   targetTable
		FROM 
			   CouponCode  targetTable
			   inner join Coupon cou
			   on targetTable.CouponId  = cou.Id
			   inner join #IntegrationAccountList i
			   on cou.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   CouponDiscount  targetTable
			   inner join Coupon cou
			   on targetTable.CouponId  = cou.Id
			   inner join #IntegrationAccountList i
			   on cou.AccountId = i.AccountId
	
		DELETE 
			   targetTable
		FROM 
			   CouponPlan  targetTable
			   inner join [Plan] pl
			   on targetTable.PlanId  = Pl.Id
			   inner join #IntegrationAccountList i
			   on pl.AccountId = i.AccountId
	
		DELETE 
			   targetTable
		FROM 
			   CouponPlanproduct  targetTable
			   inner join CouponPlan cp
			   on targetTable.CouponPlanId = cp.Id 
			   inner join Coupon c
			   on cp.CouponId  = c.Id
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   CouponPlan  targetTable
			   inner join Coupon c
			   on targetTable.CouponId  = c.Id
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   PlanProduct  targetTable
			   inner join PlanRevision pr
			   on targetTable.PlanRevisionId = pr.id
			   inner join [plan] p
			   on pr.PlanId = p.id
			   inner join #IntegrationAccountList i
			   on p.AccountId = i.AccountId

		DELETE targetTable 
		FROM 
			   PlanProductKey  targetTable
			   inner join #PlanProductKeys ppk
			   on targetTable.Id = ppk.PlanProductKey

		DROP TABLE #PlanProductKeys
	
	COMMIT TRAN;

		DELETE 
			   targetTable
		FROM 
			   PlanRevision targetTable
			   inner join [plan] p
			   on targetTable.PlanId = p.id
			   inner join #IntegrationAccountList i
			   on p.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   ProductItem targetTable
			   inner join Product p
			   on targetTable.ProductId = p.id
			   inner join #IntegrationAccountList i
			   on p.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   DiscountConfigurationFrequency  targetTable
			   INNER JOIN  DiscountConfiguration  df
			   ON df.Id = targetTable.DiscountConfigurationId
			   inner join #IntegrationAccountList i
			   on df.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   DiscountConfiguration  targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   Address targetTable
			   inner join CustomerAddressPreference cap
			   on targetTable.CustomerAddressPreferenceId = cap.id
			   inner join Customer c
			   on cap.id = c.id 
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   CustomerAddressPreference targetTable
			   inner join Customer c
			   on targetTable.id = c.id 
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   CustomerEmailPreference  targetTable
			   inner join Customer c
			   on targetTable.CustomerId = c.id 
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		UPDATE
			targetTable
		SET
			DefaultPaymentMethodId = NULL
		FROM CustomerBillingSetting targetTable
		inner join PaymentMethod pm ON targetTable.DefaultPaymentMethodId = pm.Id
		inner join Customer c
			   on pm.CustomerId = c.id 
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   CustomerBillingSetting  targetTable
			   inner join Customer c
			   on targetTable.id = c.id 
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   CreditCard targetTable
			   inner join 
			   PaymentMethod  pm
			   on targetTable.Id = pm.Id
			   inner join Customer c
			   on pm.CustomerId = c.Id 
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   AchCard targetTable
			   inner join 
			   PaymentMethod  pm
			   on targetTable.Id = pm.Id
			   inner join Customer c
			   on pm.CustomerId = c.Id 
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   BillingPeriod  targetTable
			   inner join Customer c
			   on targetTable.CustomerId = c.id 
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   BillingPeriodPaymentSchedule  targetTable
			   inner join BillingPeriodDefinition bpd
			   on targetTable.BillingPeriodDefinitionId = bpd.Id
			   inner join Customer c
			   on c.Id = bpd.CustomerId
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   BillingPeriodDefinition    targetTable
			   inner join Customer c
			   on targetTable.CustomerId = c.id 
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId
		
		DELETE 
			   targetTable
		FROM 
			   PaymentMethod  targetTable
			   inner join Customer c
			   on targetTable.CustomerId = c.Id 
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   CustomerAcquisition   targetTable
			   inner join Customer c
			   on targetTable.Id = c.id 
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   CustomerReference    targetTable
			   inner join Customer c
			   on targetTable.Id = c.id 
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   CustomerPaymentValidationLock    targetTable
			   inner join Customer c
			   on targetTable.Id = c.id 
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   CustomerEmailControl     targetTable
			   inner join Customer c
			   on targetTable.CustomerId  = c.id 
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   ProjectedInvoice     targetTable
			   inner join Customer c
			   on targetTable.CustomerId  = c.id 
			   inner join #IntegrationAccountList i
			   on c.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   Customer targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   UserDashboardWidget targetTable
			   inner join [User] u
			   on targetTable.UserId = u.id 
			   inner join AccountUser au
			   on u.Id = au.UserId 
			   inner join #IntegrationAccountList i
			   on au.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   UserAccessLink targetTable
			   inner join [User] u
			   on targetTable.UserId = u.id 
			   inner join AccountUser au
			   on u.Id = au.UserId 
			   inner join #IntegrationAccountList i
			   on au.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   UserLoginIntercept targetTable
			   inner join [User] u
			   on targetTable.UserId = u.id 
			   inner join AccountUser au
			   on u.Id = au.UserId 
			   inner join #IntegrationAccountList i
			   on au.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   UserSecurityQuestion targetTable
			   inner join [User] u
			   on targetTable.UserId = u.id 
			   inner join AccountUser au
			   on u.Id = au.UserId 
			   inner join #IntegrationAccountList i
			   on au.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   [Credential]  targetTable
			   inner join [User] u
			   on targetTable.UserId = u.id 
			   inner join AccountUser au
			   on u.id = au.UserId 
			   inner join #IntegrationAccountList i
			   on au.AccountId = i.AccountId

	BEGIN TRAN;

		Declare @UsersToCommit  table
		(
		UserId bigint
		)
		Insert into @UsersToCommit (UserId )
		Select u.Id
		FROM 
			   [User]   u
			   inner join AccountUser au
			   on u.Id = au.UserId 
			   inner join #IntegrationAccountList i
			   on au.AccountId  = i.AccountId
	
		DELETE 
			   targetTable
		FROM 
			   AccountsExcludedFromBilling  targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.AccountId  = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   AccountsExcludedFromEarning  targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.AccountId  = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   AccountUser targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.AccountId  = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   Servicetask targetTable
			   inner join ServiceJob sj
			   on targetTable.JobId = sj.Id
			   inner join #IntegrationAccountList i
			   on sj.AccountId  = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   servicejob  targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.AccountId  = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   SalesforceOneTimeAuthorizationToken  targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.AccountId  = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   AccountFeatureConfiguration  targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.Id  = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   SalesforceOneTimeAuthorizationToken   targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.AccountId  = i.AccountId
       
		DELETE 
			   targetTable
		FROM 
			   [User]  targetTable
			   inner join @UsersToCommit au
			   on targetTable.Id = au.UserId 

	COMMIT TRAN;

		DELETE 
			   targetTable
		FROM 
			   Coupon targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   AccountInvoicePreferenceLabel   targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.AccountInvoicePreferenceId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   AccountInvoicePreference   targetTable
			   inner join AccountPreference  ap
			   on targetTable.Id  = ap.id 
			   inner join #IntegrationAccountList i
			   on ap.Id = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   AccountBrandingPreference   targetTable
			   inner join AccountPreference  ap
			   on targetTable.Id  = ap.id 
			   inner join #IntegrationAccountList i
			   on ap.Id = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   AccountPreference  targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.Id = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   AccountEmailSchedule  targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   AccountEmailSchedule  targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   AccountCollectionSchedule   targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.AccountId  = i.AccountId

		DELETE 
			   targetTable 
		FROM 
			   AccountCurrency   targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.AccountId  = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   ProductCustomField    targetTable
			   inner join Product  p
			   on targetTable.ProductId   = p.id 
			   inner join #IntegrationAccountList i
			   on p.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   AccountEmailSchedule    targetTable
			   inner join AccountEmailTemplateContent aetc
			   on targetTable.AccountEmailTemplateContentId  = aetc.Id
			   inner join AccountEmailTemplate aet
			   on aet.Id = aetc.TemplateId
			   inner join #IntegrationAccountList i
			   on aet.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   AccountEmailTemplateContent    targetTable
			   inner join AccountEmailTemplate aet
			   on aet.Id = targetTable.TemplateId
			   inner join #IntegrationAccountList i
			   on aet.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   AccountEmailTemplate    targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.AccountId  = i.AccountId

		DELETE 
				targetTable
		FROM 
			   PlanFrequencyCustomField targetTable
			   inner join
			   CustomField    cf
			   on targetTable.CustomFieldId = cf.Id
			   inner join #IntegrationAccountList i
			   on cf.AccountId  = i.AccountId

		DELETE 
				targetTable
		FROM 
			   CustomField    targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.AccountId  = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   SalesTrackingCode    targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   [Plan]   targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.AccountId  = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   AccountWebhooksKey   targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.AccountId  = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   AccountBillingPreference targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.Id  = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   IntegrationSynchBatchRecord targetTable
			   inner join IntegrationSynchBatch sb
			   on targettable.IntegrationSynchBatchId  = sb.Id
			   inner join IntegrationSynchJob sj
			   on sb.IntegrationSynchJobId = sj.Id
			   inner join #IntegrationAccountList i
			   on sj.AccountId  = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   IntegrationSynchBatch targetTable
			   inner join IntegrationSynchJob sj
			   on targetTable.IntegrationSynchJobId = sj.Id
			   inner join #IntegrationAccountList i
			   on sj.AccountId  = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   IntegrationSynchJob targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.AccountId  = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   Product targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.AccountId  = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   GLCodeLedger    targetTable
			   inner join GLCode gl on gl.Id = targetTable.GlCodeId
			   inner join Product p on gl.Id = p.GLCodeId
			   inner join #IntegrationAccountList i on p.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   GLCodeLedger    targetTable
			   inner join GLCode gl on gl.Id = targetTable.GlCodeId
			   inner join #IntegrationAccountList i on gl.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   GLCode    targetTable
			   inner join Product p
			   on targetTable.Id = p.GLCodeId
			   inner join #IntegrationAccountList i
			   on p.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   GLCode    targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   ExternalApiLog    targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.AccountId = i.AccountId

	----------------------
	--COMM PLATFORM DELETION

	SET @dynsql = N'BEGIN TRAN;DELETE es 
	from 
		   '+ QUOTENAME(@CommPlatformDbName) +'.dbo.EventStatus es
		   inner join '+ QUOTENAME(@CommPlatformDbName) +'.dbo.Events e
		   on es.EventId = e.id
		   inner join '+ QUOTENAME(@CommPlatformDbName) +'.dbo.Transactions t
		   on e.TransactionId = t.id 
		   inner join '+ QUOTENAME(@CommPlatformDbName) +'.dbo.Accounts a
		   on t.AccountId = a.id 
		   inner join #IntegrationAccountList ial
		   on a.ExternalAccountId = ial.AccountId 
	COMMIT TRAN;'
	EXEC sp_executesql @dynsql;

	SET @dynsql = N'BEGIN TRAN;DELETE e
	from 
		   '+ QUOTENAME(@CommPlatformDbName) +'.dbo.Events e
		   inner join '+ QUOTENAME(@CommPlatformDbName) +'.dbo.Transactions t
		   on e.TransactionId = t.id 
		   inner join '+ QUOTENAME(@CommPlatformDbName) +'.dbo.Accounts a
		   on t.AccountId = a.id 
		   inner join #IntegrationAccountList ial
		   on a.ExternalAccountId = ial.AccountId 
	COMMIT TRAN;'
	EXEC sp_executesql @dynsql;

	SET @dynsql = N'BEGIN TRAN;DELETE t
	from 
		   '+ QUOTENAME(@CommPlatformDbName) +'.dbo.Transactions t
		   inner join '+ QUOTENAME(@CommPlatformDbName) +'.dbo.Accounts a
		   on t.AccountId = a.id 
		   inner join #IntegrationAccountList ial
		   on a.ExternalAccountId = ial.AccountId 
	COMMIT TRAN;'
	EXEC sp_executesql @dynsql;

	SET @dynsql = N'BEGIN TRAN;DELETE acc
	from 
		   '+ QUOTENAME(@CommPlatformDbName) +'.dbo.AccountChannelConfigurations acc
		   inner join '+ QUOTENAME(@CommPlatformDbName) +'.dbo.AccountChannels ac
		   on acc.AccountChannelId = ac.Id 
		   inner join '+ QUOTENAME(@CommPlatformDbName) +'.dbo.Accounts a
		   on ac.AccountId = a.Id 
		   inner join #IntegrationAccountList ial
		   on a.ExternalAccountId = ial.AccountId 
	COMMIT TRAN;'
	EXEC sp_executesql @dynsql;

	SET @dynsql = N'BEGIN TRAN;DELETE acr
	from 
		   '+ QUOTENAME(@CommPlatformDbName) +'.dbo.AccountChannelRoutes  acr
		   inner join '+ QUOTENAME(@CommPlatformDbName) +'.dbo.AccountChannels ac
		   on acr.AccountChannelId = ac.Id 
		   inner join '+ QUOTENAME(@CommPlatformDbName) +'.dbo.Accounts a
		   on ac.AccountId = a.Id 
		   inner join #IntegrationAccountList ial
		   on a.ExternalAccountId = ial.AccountId 
	COMMIT TRAN;'
	EXEC sp_executesql @dynsql;

	SET @dynsql = N'BEGIN TRAN;DELETE ac
	from 
		   '+ QUOTENAME(@CommPlatformDbName) +'.dbo.AccountChannels ac
		   inner join '+ QUOTENAME(@CommPlatformDbName) +'.dbo.Accounts a
		   on ac.AccountId = a.Id 
		   inner join #IntegrationAccountList ial
		   on a.ExternalAccountId = ial.AccountId 
	COMMIT TRAN;'
	EXEC sp_executesql @dynsql;

	SET @dynsql = N'BEGIN TRAN;DELETE a
	from 
		   '+ QUOTENAME(@CommPlatformDbName) +'.dbo.Accounts a
		   inner join #IntegrationAccountList ial
		   on a.ExternalAccountId = ial.AccountId 
	COMMIT TRAN;'
	EXEC sp_executesql @dynsql;
-------------------------

		DELETE 
			   targetTable
		FROM 
			   ServiceTask   targetTable
			   inner join ServiceJob sj on targetTable.JobId = sj.Id
			   inner join #IntegrationAccountList i
			   on sj.AccountId  = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   ServiceJob   targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.AccountId  = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   Accountsalesforceconfiguration   targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.Id  = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   AccountDigitalRiverECCN   targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.AccountId  = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   AccountDigitalRiverTaxCode   targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.AccountId  = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   AccountDigitalRiverConfiguration   targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.Id  = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   AccountBilling   targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.AccountId  = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   AccountAddressPreference   targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.Id  = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   AccountGatewayReconciliation   targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.Id  = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   AccountMerchantCardRate   targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.AccountId  = i.AccountId

		DELETE 
				targetTable
		From
				AccountEarning		targetTable
				inner join #IntegrationAccountList i
				on targetTable.Accountid = i.AccountId
		DELETE 
			   targetTable
		FROM 
			   AccountLimit   targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.AccountId  = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   AccountChannelBulkEventExclusion   targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.AccountId  = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   AccountAutomatedHistory  targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.AccountId  = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   StaxGatewayFeeBatchLogging targetTable
			   inner join StaxGatewayFeeLogging r
				on r.Id = targetTable.StaxGatewayFeeLoggingId			   
			   inner join #IntegrationAccountList i
			   on r.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   StaxGatewayFeeLogging targetTable			  
			   inner join #IntegrationAccountList i
			   on targetTable.AccountId = i.AccountId

		DELETE 
			   targetTable
		FROM 
			   Account   targetTable
			   inner join #IntegrationAccountList i
			   on targetTable.Id  = i.AccountId

	drop table #IntegrationAccountList

	--DROP TEMP FK INDEXES TO OPTIMISE BULK DELETION
	IF EXISTS(SELECT * FROM sys.indexes WHERE object_id = object_id('dbo.SubscriptionProduct') AND NAME ='TEMP_FKIX_SubscriptionProduct_PlanProductId')
		DROP INDEX [TEMP_FKIX_SubscriptionProduct_PlanProductId] ON [dbo].[SubscriptionProduct]

	IF EXISTS(SELECT * FROM sys.indexes WHERE object_id = object_id('dbo.PaymentActivityJournal') AND NAME ='TEMP_FKIX_PaymentActivityJournal_ParentCustomerId')
		DROP INDEX [TEMP_FKIX_PaymentActivityJournal_ParentCustomerId] ON [dbo].[PaymentActivityJournal]

	IF EXISTS(SELECT * FROM sys.indexes WHERE object_id = object_id('dbo.PlanFamilyRelationshipMapping') AND NAME ='TEMP_FKIX_PlanFamilyRelationshipMapping_SourcePlanProductId')
		DROP INDEX [TEMP_FKIX_PlanFamilyRelationshipMapping_SourcePlanProductId] ON [dbo].[PlanFamilyRelationshipMapping]

	IF EXISTS(SELECT * FROM sys.indexes WHERE object_id = object_id('dbo.PlanFamilyRelationshipMapping') AND NAME ='TEMP_FKIX_PlanFamilyRelationshipMapping_DestinationPlanProductId')
		DROP INDEX [TEMP_FKIX_PlanFamilyRelationshipMapping_DestinationPlanProductId] ON [dbo].[PlanFamilyRelationshipMapping]

	----------

END TRY
BEGIN CATCH

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

    EXEC dbo.usp_ErrorHandler

    RETURN 55555

END CATCH

GO

