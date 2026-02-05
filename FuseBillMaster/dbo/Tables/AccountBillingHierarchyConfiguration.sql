CREATE TABLE [dbo].[AccountBillingHierarchyConfiguration] (
    [Id]                          BIGINT   NOT NULL,
    [SubscriptionMonthlyOptionId] TINYINT  NOT NULL,
    [SubscriptionYearlyOptionId]  TINYINT  NOT NULL,
    [PurchaseOptionId]            TINYINT  NOT NULL,
    [ModifiedTimestamp]           DATETIME NOT NULL,
    [HierarchySuspendOptionId]    INT      NOT NULL,
    [SubscriptionWeeklyOptionId]  TINYINT  CONSTRAINT [DF_SubscriptionWeeklyOptionId] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_AccountBillingHierarchyConfiguration] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_AccountBillingHierarchyConfiguration_Account] FOREIGN KEY ([Id]) REFERENCES [dbo].[Account] ([Id]) ON DELETE CASCADE,
    CONSTRAINT [FK_AccountBillingHierarchyConfiguration_HierarchyConfigurationOptionMonthly] FOREIGN KEY ([SubscriptionMonthlyOptionId]) REFERENCES [Lookup].[HierarchyConfigurationOption] ([Id]),
    CONSTRAINT [FK_AccountBillingHierarchyConfiguration_HierarchyConfigurationOptionPurchase] FOREIGN KEY ([PurchaseOptionId]) REFERENCES [Lookup].[HierarchyConfigurationOption] ([Id]),
    CONSTRAINT [FK_AccountBillingHierarchyConfiguration_HierarchyConfigurationOptionYearly] FOREIGN KEY ([SubscriptionYearlyOptionId]) REFERENCES [Lookup].[HierarchyConfigurationOption] ([Id]),
    CONSTRAINT [FK_AccountBillingHierarchyConfiguration_HierarchySuspendOption] FOREIGN KEY ([HierarchySuspendOptionId]) REFERENCES [Lookup].[HierarchySuspendOptions] ([Id])
);


GO

