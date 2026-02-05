CREATE TABLE [dbo].[Subscription] (
    [Id]                                   BIGINT          IDENTITY (1, 1) NOT NULL,
    [CustomerId]                           BIGINT          NOT NULL,
    [CreatedTimestamp]                     DATETIME        NOT NULL,
    [ModifiedTimestamp]                    DATETIME        NOT NULL,
    [StatusId]                             INT             NOT NULL,
    [PlanFrequencyId]                      BIGINT          NOT NULL,
    [ActivationTimestamp]                  DATETIME        NULL,
    [CancellationTimestamp]                DATETIME        NULL,
    [ScheduledActivationTimestamp]         DATETIME        NULL,
    [ProvisionedTimestamp]                 DATETIME        NULL,
    [RemainingInterval]                    INT             NULL,
    [InvoiceDay]                           INT             NULL,
    [Reference]                            NVARCHAR (255)  NULL,
    [AutoApplyCatalogChanges]              BIT             NOT NULL,
    [MonthlyRecurringRevenue]              MONEY           CONSTRAINT [DF_Subscription_MonthlyRecurringRevenue] DEFAULT ((0)) NOT NULL,
    [Amount]                               MONEY           CONSTRAINT [DF_SubscriptionAmount] DEFAULT ((0)) NOT NULL,
    [SalesforceId]                         NVARCHAR (255)  NULL,
    [ContractStartTimestamp]               DATETIME        NULL,
    [ContractEndTimestamp]                 DATETIME        NULL,
    [NetMRR]                               MONEY           NOT NULL,
    [NetsuiteId]                           NVARCHAR (255)  NULL,
    [BillingPeriodDefinitionId]            BIGINT          NULL,
    [ExpiredTimestamp]                     DATETIME        NULL,
    [PlanName]                             NVARCHAR (100)  NOT NULL,
    [PlanCode]                             NVARCHAR (255)  NOT NULL,
    [PlanDescription]                      NVARCHAR (1000) NULL,
    [PlanLongDescription]                  NVARCHAR (4000) NULL,
    [PlanReference]                        NVARCHAR (255)  NULL,
    [PlanFrequencyUniqueId]                BIGINT          NOT NULL,
    [PlanId]                               BIGINT          NOT NULL,
    [IntervalId]                           INT             NOT NULL,
    [NumberOfIntervals]                    INT             NOT NULL,
    [RemainingIntervalPushOut]             INT             NULL,
    [CurrentMrr]                           MONEY           DEFAULT ((0)) NOT NULL,
    [CurrentNetMrr]                        MONEY           DEFAULT ((0)) NOT NULL,
    [MigratedTimestamp]                    DATETIME        NULL,
    [InvoiceInAdvance]                     TINYINT         CONSTRAINT [DF_Subscription_InvoiceInAdvance] DEFAULT ((0)) NOT NULL,
    [HubSpotDealId]                        BIGINT          NULL,
    [IsDeleted]                            BIT             CONSTRAINT [DF_Subscription_IsDeleted] DEFAULT ((0)) NOT NULL,
    [GeotabDevicePlanId]                   NVARCHAR (255)  NULL,
    [QuickBooksClassId]                    VARCHAR (50)    NULL,
    [RemainingRefreshPriceInterval]        INT             NULL,
    [RemainingRefreshPriceIntervalPushOut] INT             NULL,
    [PriceWasRefreshedAtLastInterval]      BIT             CONSTRAINT [DF_PriceWasRefreshedAtLastInterval] DEFAULT ((0)) NOT NULL,
    [SourceSubscriptionId]                 BIGINT          NULL,
    [InvoiceWeekday]                       INT             NULL,
    [AccountId]                            BIGINT          NOT NULL,
    CONSTRAINT [PK_Subscription] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    FOREIGN KEY ([InvoiceWeekday]) REFERENCES [Lookup].[Weekday] ([Id]),
    CONSTRAINT [FK_Subscription_AccountId] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id]),
    CONSTRAINT [FK_Subscription_BillingPeriodDefinition] FOREIGN KEY ([BillingPeriodDefinitionId]) REFERENCES [dbo].[BillingPeriodDefinition] ([Id]),
    CONSTRAINT [FK_Subscription_CustomerId] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([Id]),
    CONSTRAINT [FK_Subscription_IntervalId] FOREIGN KEY ([IntervalId]) REFERENCES [Lookup].[Interval] ([Id]),
    CONSTRAINT [FK_Subscription_IntervalPrice] FOREIGN KEY ([PlanFrequencyId]) REFERENCES [dbo].[PlanFrequency] ([Id]),
    CONSTRAINT [FK_Subscription_PlanFrequencyUniquelId] FOREIGN KEY ([PlanFrequencyUniqueId]) REFERENCES [dbo].[PlanFrequencyKey] ([Id]),
    CONSTRAINT [FK_Subscription_PlanId] FOREIGN KEY ([PlanId]) REFERENCES [dbo].[Plan] ([Id]),
    CONSTRAINT [FK_Subscription_SubscriptionStatus] FOREIGN KEY ([StatusId]) REFERENCES [Lookup].[SubscriptionStatus] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_Subscription_PlanFrequencyId]
    ON [dbo].[Subscription]([PlanFrequencyId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_Subscription_BillingPeriodDefinitionId]
    ON [dbo].[Subscription]([BillingPeriodDefinitionId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_Subscription_Reference]
    ON [dbo].[Subscription]([Reference] ASC)
    INCLUDE([Id], [CustomerId]) WITH (FILLFACTOR = 100);


GO

CREATE NONCLUSTERED INDEX [FKIX_Subscription_IntervalId]
    ON [dbo].[Subscription]([IntervalId] ASC) WITH (FILLFACTOR = 100);


GO

CREATE NONCLUSTERED INDEX [IX_Subscription_StatusId_CancellationTimestamp]
    ON [dbo].[Subscription]([StatusId] ASC, [CancellationTimestamp] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_Subscription_PlanFrequencyUniqueId]
    ON [dbo].[Subscription]([PlanFrequencyUniqueId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_Subscription_StatusId_ScheduledActivationTimestamp]
    ON [dbo].[Subscription]([StatusId] ASC, [ScheduledActivationTimestamp] ASC)
    INCLUDE([Id], [CustomerId], [PlanFrequencyId]) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_Subscription_PlanId]
    ON [dbo].[Subscription]([PlanId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_Subscription_AccountId_StatusId_IsDeleted]
    ON [dbo].[Subscription]([AccountId] ASC, [StatusId] ASC, [IsDeleted] ASC)
    INCLUDE([Id], [CustomerId]);


GO

CREATE NONCLUSTERED INDEX [IX_Subscription_AccountId_StatusId]
    ON [dbo].[Subscription]([AccountId] ASC, [StatusId] ASC)
    INCLUDE([Id]);


GO

CREATE NONCLUSTERED INDEX [IX_Subscription_CustomerId_StatusId]
    ON [dbo].[Subscription]([CustomerId] ASC, [StatusId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

