CREATE PROCEDURE [dbo].[usp_GetFullAccount]
	@AccountId bigint
AS
BEGIN
	set transaction isolation level snapshot

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
		*
		,[TypeId] as [Type]
	FROM Account WHERE Id = @AccountId

	SELECT 
		* 
		,TaxOptionId AS TaxOption
		,CustomerGridDisplayOptionId AS CustomerGridDisplayOption
		,CustomerGridNameDisplayOptionId AS CustomerGridNameDisplayOption
	FROM AccountFeatureConfiguration WHERE Id = @AccountId

	SELECT 
		*, 
		DefaultCustomerServiceStartOptionId as DefaultCustomerServiceStartOption,
		RechargeTypeId as RechargeType,
		DefaultTermId as DefaultTerm
	FROM AccountBillingPreference WHERE Id = @AccountId

	SELECT 
		*, 
		TypeId as [Type], 
		RuleId as [Rule],
		IntervalId as [Interval]
	FROM AccountBillingPeriodConfiguration WHERE AccountBillingPreferenceId = @AccountId

	SELECT * FROM AccountPreference WHERE Id = @AccountId

	SELECT * FROM AccountBrandingPreference WHERE Id = @AccountId

	SELECT 
		*, 
		CurrencyStatusId as CurrencyStatus
	FROM AccountCurrency WHERE AccountId = @AccountId

	SELECT 
		c.*
	FROM AccountCurrency ac
	INNER JOIN Lookup.Currency c ON c.Id = ac.CurrencyId
	WHERE ac.AccountId = @AccountId

	SELECT 
		*, 
		InvoiceCustomerReferenceOption as InvoiceCustomerReferenceOption,
		ChargeGroupOrderId as ChargeGroupOrder,
		LayoutId as Layout,
		TrackedItemDisplayFormatId as TrackedItemDisplayFormat
	FROM AccountInvoicePreference WHERE Id = @AccountId

	SELECT
		*
		, InvoicePreferenceLabelId as InvoicePreferenceLabel
	FROM AccountInvoicePreferenceLabel
	WHERE AccountInvoicePreferenceId = @AccountId

	SELECT Lookup.Timezone.* 
	FROM AccountPreference
	INNER JOIN Lookup.Timezone ON Lookup.Timezone.Id = AccountPreference.TimezoneId
	WHERE AccountPreference.Id = @AccountId

	SELECT 
		*
	FROM AccountSalesTrackingCodeConfiguration
	WHERE Id = @AccountId

	SELECT *
		, [TypeId] as [Type]
		, EmailCategoryId as [EmailCategory]
	FROM AccountEmailTemplate
	WHERE AccountId = @AccountId

	SELECT * FROM AvalaraConfiguration WHERE Id = @AccountId

	SELECT * FROM AvalaraConfigurationBySalesTrackingCode WHERE AvalaraConfigurationId = @AccountId

	SELECT 
		*, 
		OptionId as [Option], 
		TypeId as [Type], 
		IntervalId as [Interval], 
		TrackedItemDisplayFormatId as TrackedItemDisplayFormat,
		StatementActivityTypeId as [StatementActivityType]
	FROM AccountBillingStatementPreference WHERE Id = @AccountId

	SELECT * FROM AccountInvoicePreferenceDisplayField
	WHERE Id = @AccountId

	SELECT 
		*, 
		EntityTypeId as EntityType, 
		CategoryId as Category
	FROM [dbo].[AccountDisplaySetting]
	WHERE AccountId = @AccountId
	ORDER BY Category, [Key]

	SELECT * FROM AccountAddressPreference
	WHERE Id = @AccountId

	SELECT *
		, TaxRecognitionOptionId as TaxRecognitionOption 
		, StatusId as [Status]
	FROM AccountQuickBooksOnlineConfig WHERE Id = @AccountId

	SELECT * 
		, StatusId as [Status]
	FROM AccountSageIntacctConfiguration WHERE Id = @AccountId

	SELECT *
	FROM AccountDigitalRiverConfiguration WHERE Id = @AccountId

	SELECT *
		, LateInvoiceOptionId as LateInvoiceOption
		, PartialReverseChargeOptionId as PartialReverseChargeOption
		, UnsuspendEarningOptionId as UnsuspendEarningOption
		, UnholdEarningOptionId as UnholdEarningOption
	FROM AccountAccountingPreference WHERE Id = @AccountId

	SELECT * FROM AccountGatewayReconciliation
	WHERE Id = @AccountId

	SELECT *
	FROM AccountMerchantCardRate
	WHERE AccountId = @AccountId

	;WITH MostRecentCurrencyExchange AS (
	Select 
		currencyid
		, Max(Id) as Id
	from 
		[AccountQuickBooksOnlineCurrencyExchange] 
	Where
		AccountId = @AccountId
		and EffectiveTimestamp < GETUTCDATE()
	Group by currencyId 
	)
	SELECT
		qex.*
	FROM [AccountQuickBooksOnlineCurrencyExchange] qex
	INNER JOIN MostRecentCurrencyExchange mrc ON mrc.Id = qex.Id

	SELECT 
		*,
		[EntityTypeId] as [EntityType]
	FROM AccountLimit
	WHERE [AccountId] = @AccountId

	SELECT 
		*
		, DefaultAccountTypeId as DefaultAccountType
		, SalesforceCatalogSyncStatusId as SalesforceCatalogSyncStatus
	FROM AccountSalesforceConfiguration
	WHERE Id = @AccountId

	SELECT
		* 
	FROM [dbo].[AccountChannelBulkEventExclusion]
	WHERE AccountId = @AccountId

	SELECT
		* 
	FROM [dbo].[AccountNetsuiteConfiguration]
	WHERE Id = @AccountId

	SELECT
		*
		,DealUpdateTypeId as DealUpdateType
	FROM [dbo].[AccountHubSpotConfiguration]
	WHERE Id = @AccountId

	SELECT
		* 
	FROM [dbo].[AccountTxtTemplate]
	WHERE AccountId = @AccountId

	SELECT 
		*
		,HierarchySuspendOptionId as HierarchySuspendOption
	FROM [AccountBillingHierarchyConfiguration] WHERE Id = @AccountId

	SELECT
		sp.* 
	FROM [dbo].[AccountServiceProviderTemplate] sp
	INNER JOIN Account a ON sp.Id = a.AccountServiceProviderId
	WHERE a.Id = @AccountId

	SELECT 
		*
	FROM AccountGeotabConfiguration WHERE Id = @AccountId

	SELECT
		*
	FROM AccountGeotabDevicePlan WHERE AccountId = @AccountId

	SELECT 
		*
	FROM AnrokConfiguration WHERE Id = @AccountId

END

GO

