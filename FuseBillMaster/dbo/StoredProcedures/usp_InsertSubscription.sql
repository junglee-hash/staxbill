
CREATE       PROC [dbo].[usp_InsertSubscription] 
    @CustomerId bigint,
    @CreatedTimestamp datetime,
    @ModifiedTimestamp datetime,
    @StatusId int,
    @PlanFrequencyId bigint,
    @ActivationTimestamp datetime = NULL,
    @CancellationTimestamp datetime = NULL,
    @ScheduledActivationTimestamp datetime = NULL,
    @ProvisionedTimestamp datetime = NULL,
    @RemainingInterval int = NULL,
    @InvoiceDay int,
    @Reference nvarchar(255) = NULL,
    @AutoApplyCatalogChanges bit,
    @MonthlyRecurringRevenue money,
    @Amount money,
    @SalesforceId nvarchar(255) = NULL,
    @ContractStartTimestamp datetime = NULL,
    @ContractEndTimestamp datetime = NULL,
    @NetMRR money,
    @NetsuiteId nvarchar(255) = NULL,
    @BillingPeriodDefinitionId bigint = NULL,
    @ExpiredTimestamp datetime = NULL,
    @PlanName nvarchar(100),
    @PlanCode nvarchar(255),
    @PlanDescription nvarchar(1000) = NULL,
    @PlanLongDescription nvarchar(4000) = NULL,
    @PlanReference nvarchar(255) = NULL,
    @PlanFrequencyUniqueId bigint,
    @PlanId bigint,
    @IntervalId int,
    @NumberOfIntervals int,
    @RemainingIntervalPushOut int = NULL,
    @CurrentMrr money,
    @CurrentNetMrr money,
    @MigratedTimestamp datetime = NULL,
    @InvoiceInAdvance tinyint,
    @HubSpotDealId bigint = NULL,
    @GeotabDevicePlanId NVARCHAR(255) = NULL,
	@QuickBooksClassId VARCHAR(50) = NULL,
	@RemainingRefreshPriceInterval INT = NULL,
	@RemainingRefreshPriceIntervalPushOut INT = NULL,
	@PriceWasRefreshedAtLastInterval BIT,
	@SourceSubscriptionId bigint = null,
	@InvoiceWeekday int = null,
	@AccountId bigint = null
AS 
	SET NOCOUNT ON

	UPDATE PlanFrequency SET NumberOfSubscriptions = NumberOfSubscriptions + 1
	WHERE PlanFrequencyUniqueId = @PlanFrequencyUniqueId

	INSERT INTO [dbo].[Subscription] ([CustomerId], [CreatedTimestamp], [ModifiedTimestamp], [StatusId], [PlanFrequencyId], [ActivationTimestamp], [CancellationTimestamp], [ScheduledActivationTimestamp], [ProvisionedTimestamp], [RemainingInterval], [InvoiceDay], [Reference], [AutoApplyCatalogChanges], [MonthlyRecurringRevenue], [Amount], [SalesforceId], [ContractStartTimestamp], [ContractEndTimestamp], [NetMRR], [NetsuiteId], [BillingPeriodDefinitionId], [ExpiredTimestamp], [PlanName], [PlanCode], [PlanDescription], [PlanLongDescription], [PlanReference], [PlanFrequencyUniqueId], [PlanId], [IntervalId], [NumberOfIntervals], [RemainingIntervalPushOut], [CurrentMrr], [CurrentNetMrr], [MigratedTimestamp], [InvoiceInAdvance], [HubSpotDealId], [GeotabDevicePlanId], [QuickbooksClassId], [RemainingRefreshPriceInterval], [RemainingRefreshPriceIntervalPushOut], [PriceWasRefreshedAtLastInterval], [SourceSubscriptionId], [InvoiceWeekday], [AccountId])
	SELECT 
	@CustomerId, 
	@CreatedTimestamp, 
	GETUTCDATE(), --modified timestamp.
	@StatusId, @PlanFrequencyId, @ActivationTimestamp, @CancellationTimestamp, @ScheduledActivationTimestamp, @ProvisionedTimestamp, @RemainingInterval, @InvoiceDay, @Reference, @AutoApplyCatalogChanges, @MonthlyRecurringRevenue, @Amount, @SalesforceId, @ContractStartTimestamp, @ContractEndTimestamp, @NetMRR, @NetsuiteId, @BillingPeriodDefinitionId, @ExpiredTimestamp, @PlanName, @PlanCode, @PlanDescription, @PlanLongDescription, @PlanReference, @PlanFrequencyUniqueId, @PlanId, @IntervalId, @NumberOfIntervals, @RemainingIntervalPushOut, @CurrentMrr, @CurrentNetMrr, @MigratedTimestamp, @InvoiceInAdvance, @HubSpotDealId, @GeotabDevicePlanId, @QuickBooksClassId, @RemainingRefreshPriceInterval, @RemainingRefreshPriceIntervalPushOut, @PriceWasRefreshedAtLastInterval, @SourceSubscriptionId, @InvoiceWeekday, @AccountId

	SELECT SCOPE_IDENTITY() As InsertedID

	SET NOCOUNT OFF

GO

