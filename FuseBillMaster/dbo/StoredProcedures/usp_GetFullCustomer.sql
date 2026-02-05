CREATE    PROCEDURE [dbo].[usp_GetFullCustomer]
	@customerIds AS dbo.IDList READONLY,
	@onlyIncludeOpenBillingPeriods BIT,
	@includeDefaultPaymentMethod BIT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

declare @customers table
(
SortOrder INT
,CustomerId bigint
)

INSERT INTO @customers (SortOrder,CustomerId)
select 
ROW_NUMBER() OVER (ORDER BY (SELECT 100)) AS [SortOrder]
,i.Id 
FROM @customerIds i
INNER JOIN Customer c on c.Id = i.Id
WHERE c.IsDeleted = 0

	SELECT c.*
		, c.AccountStatusId as AccountStatus
		, c.NetsuiteEntityTypeId as NetsuiteEntityType
		, c.QuickBooksLatchTypeId as QuickBooksLatchType
		, c.SalesforceAccountTypeId as SalesforceAccountType
		, c.SalesforceSynchStatusId as SalesforceSynchStatus
		, c.StatusId as [Status]
		, c.TitleId as [Title]
	  FROM [dbo].[Customer] c
	INNER JOIN @customers cus ON Id = cus.CustomerId
	ORDER BY cus.SortOrder

	SELECT cbs.*
		, cbs.TermId as [Term]
		, cbs.IntervalId as [Interval]
		, cbs.CustomerServiceStartOptionId as [CustomerServiceStartOption]
		, cbs.RechargeTypeId as [RechargeType]
		, cbs.HierarchySuspendOptionId as [HierarchySuspendOption]
	  FROM [dbo].[CustomerBillingSetting] cbs
	INNER JOIN @customers cus ON Id = cus.CustomerId

	SELECT
		  bpd.*
		  ,[IntervalId] as Interval
		  ,[BillingPeriodTypeId] as BillingPeriodType
	  FROM [dbo].[BillingPeriodDefinition] bpd
	INNER JOIN @customers cus ON bpd.CustomerId = cus.CustomerId

	SELECT 
			bp.*
		  ,[PeriodStatusId] as PeriodStatus
	  FROM [dbo].[BillingPeriod] bp
	INNER JOIN @customers cus ON bp.CustomerId = cus.CustomerId
	WHERE (bp.PeriodStatusId = 1 --open
		OR @onlyIncludeOpenBillingPeriods = 0)

	SELECT
		  bpps.*
	  FROM BillingPeriodPaymentSchedule bpps
	  INNER JOIN [dbo].[BillingPeriodDefinition] bpd ON bpd.Id = bpps.BillingPeriodDefinitionId
	INNER JOIN @customers cus ON bpd.CustomerId = cus.CustomerId

	SELECT 
		cis.*
	  ,[TrackedItemDisplayFormatId] as TrackedItemDisplayFormat
	   FROM CustomerInvoiceSetting cis
	INNER JOIN @customers cus ON cis.Id = cus.CustomerId

	SELECT * FROM CustomerEmailPreference cep
	INNER JOIN @customers cus ON cep.CustomerId = cus.CustomerId

	SELECT [Id]
			,[CustomerBillingSettingId]
			,[IntervalId] as Interval
			,[Month]
			,[Day]
			,[Weekday]
			,[TypeId] as [Type]
			,[RuleId] as [Rule]
			,[CreatedTimestamp]
			,[ModifiedTimestamp]
		FROM [dbo].[CustomerBillingPeriodConfiguration]
	INNER JOIN @customers cus ON CustomerBillingSettingId = cus.CustomerId

	SELECT *
		  ,[StatusId] as [Status]
	  FROM [dbo].[CustomerStatusJournal] csj
	  INNER JOIN @customers cus ON csj.CustomerId = cus.CustomerId AND IsActive = 1

	SELECT *
		  ,[StatusId] as [Status]
	  FROM [dbo].[CustomerAccountStatusJournal] csj
	INNER JOIN @customers cus ON csj.CustomerId = cus.CustomerId AND IsActive = 1

	SELECT * FROM CustomerAcquisition 
	INNER JOIN @customers cus ON Id = cus.CustomerId

	SELECT * FROM CustomerReference 
	INNER JOIN @customers cus ON Id = cus.CustomerId

	SELECT * FROM CustomerCredential 
	INNER JOIN @customers cus ON Id = cus.CustomerId

	SELECT * FROM CustomerAddressPreference 
	INNER JOIN @customers cus ON Id = cus.CustomerId

	SELECT *
		  ,[AddressTypeId] as AddressType
		  ,[Country] as Country1
		  ,[State] as State1
	  FROM [dbo].[Address]
	INNER JOIN @customers cus ON CustomerAddressPreferenceId = cus.CustomerId

	SELECT sc1.*
		  ,sc1.[TypeId] as [Type]
		  ,sc1.[StatusId] as [Status]
	  FROM [dbo].[SalesTrackingCode] sc1
	INNER JOIN CustomerReference cr ON sc1.Id = cr.SalesTrackingCode1Id
	INNER JOIN @customers cus ON cr.Id = cus.CustomerId
	UNION ALL
	SELECT sc2.*
		  ,sc2.[TypeId] as [Type]
		  ,sc2.[StatusId] as [Status]
	  FROM [dbo].[SalesTrackingCode] sc2
	INNER JOIN CustomerReference cr ON sc2.Id = cr.SalesTrackingCode2Id
	INNER JOIN @customers cus ON cr.Id = cus.CustomerId
	UNION ALL
	SELECT sc3.*
		  ,sc3.[TypeId] as [Type]
		  ,sc3.[StatusId] as [Status]
	  FROM [dbo].[SalesTrackingCode] sc3
	INNER JOIN CustomerReference cr ON sc3.Id = cr.SalesTrackingCode3Id
	INNER JOIN @customers cus ON cr.Id = cus.CustomerId
	UNION ALL
	SELECT sc4.*
		  ,sc4.[TypeId] as [Type]
		  ,sc4.[StatusId] as [Status]
	  FROM [dbo].[SalesTrackingCode] sc4
	INNER JOIN CustomerReference cr ON sc4.Id = cr.SalesTrackingCode4Id
	INNER JOIN @customers cus ON cr.Id = cus.CustomerId
	UNION ALL
	SELECT sc5.*
		  ,sc5.[TypeId] as [Type]
		  ,sc5.[StatusId] as [Status]
	  FROM [dbo].[SalesTrackingCode] sc5
	INNER JOIN CustomerReference cr ON sc5.Id = cr.SalesTrackingCode5Id
	INNER JOIN @customers cus ON cr.Id = cus.CustomerId

	SELECT Id, 
		OptionId as [Option], 
		TypeId as [Type], 
		IntervalId as [Interval], 
		[Day], 
		[Month], 
		ShowTrackedItemName, 
		ShowTrackedItemReference, 
		ShowTrackedItemDescription, 
		TrackedItemDisplayFormatId as TrackedItemDisplayFormat,
		ShowTrackedItemCreatedDate,
		Modifiedtimestamp,
		StatementActivityTypeId as [StatementActivityType]
	FROM CustomerBillingStatementSetting
	INNER JOIN @customers cus ON Id = cus.CustomerId

		SELECT ci.*
	FROM CustomerIntegration ci
	INNER JOIN @customers cus ON ci.CustomerId = cus.CustomerId

	SELECT sms.*
	FROM [dbo].[CustomerSmsNumber] sms
	INNER JOIN @customers cus ON sms.CustomerId = cus.CustomerId

	SELECT sms.*
	FROM [dbo].[CustomerTxtPreference] sms
	INNER JOIN @customers cus ON sms.CustomerId = cus.CustomerId

	SELECT cpvl.*
	FROM [dbo].[CustomerPaymentValidationLock] cpvl
	INNER JOIN @customers cus ON cpvl.Id = cus.CustomerId

	IF (@includeDefaultPaymentMethod = 1)
	BEGIN
		SELECT pm.*
			, [PaymentMethodStatusId] as [PaymentMethodStatus]
			, [PaymentMethodTypeId] as [PaymentMethodType]
		FROM CustomerBillingSetting cbs
		INNER JOIN @customers cus ON cbs.Id = cus.CustomerId
		INNER JOIN PaymentMethod pm ON pm.Id = cbs.DefaultPaymentMethodId
	END

END

GO

