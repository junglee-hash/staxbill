CREATE TABLE [dbo].[CustomerBillingStatementSetting] (
    [Id]                         BIGINT   NOT NULL,
    [OptionId]                   INT      NULL,
    [TypeId]                     INT      NULL,
    [IntervalId]                 INT      NULL,
    [Day]                        INT      NULL,
    [Month]                      INT      NULL,
    [ShowTrackedItemName]        BIT      NULL,
    [ShowTrackedItemReference]   BIT      NULL,
    [ShowTrackedItemDescription] BIT      NULL,
    [TrackedItemDisplayFormatId] INT      NULL,
    [ShowTrackedItemCreatedDate] BIT      CONSTRAINT [DF_ShowTrackedItemCreatedDate_CustomerBillingStatementSetting] DEFAULT ((0)) NULL,
    [ModifiedTimestamp]          DATETIME NOT NULL,
    [StatementActivityTypeId]    INT      NULL,
    CONSTRAINT [PK_CustomerBillingStatementSetting] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_CustomerBillingStatement_StatementActivityType] FOREIGN KEY ([StatementActivityTypeId]) REFERENCES [Lookup].[StatementActivityType] ([Id]),
    CONSTRAINT [FK_CustomerBillingStatementSetting_BillingStatementOption] FOREIGN KEY ([OptionId]) REFERENCES [Lookup].[BillingStatementOption] ([Id]),
    CONSTRAINT [FK_CustomerBillingStatementSetting_BillingStatementType] FOREIGN KEY ([TypeId]) REFERENCES [Lookup].[BillingStatementType] ([Id]),
    CONSTRAINT [FK_CustomerBillingStatementSetting_Customer] FOREIGN KEY ([Id]) REFERENCES [dbo].[Customer] ([Id]) ON DELETE CASCADE,
    CONSTRAINT [FK_CustomerBillingStatementSetting_CustomerBillingSetting] FOREIGN KEY ([Id]) REFERENCES [dbo].[Customer] ([Id]),
    CONSTRAINT [FK_CustomerBillingStatementSetting_Interval] FOREIGN KEY ([IntervalId]) REFERENCES [Lookup].[Interval] ([Id]),
    CONSTRAINT [FK_CustomerBillingStatementSetting_TrackedItemDisplayFormat] FOREIGN KEY ([TrackedItemDisplayFormatId]) REFERENCES [Lookup].[TrackedItemDisplayFormat] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_CustomerBillingStatementSetting_OptionId]
    ON [dbo].[CustomerBillingStatementSetting]([OptionId] ASC) WITH (FILLFACTOR = 100);


GO

CREATE NONCLUSTERED INDEX [FKIX_CustomerBillingStatementSetting_TrackedItemDisplayFormatId]
    ON [dbo].[CustomerBillingStatementSetting]([TrackedItemDisplayFormatId] ASC) WITH (FILLFACTOR = 100);


GO

CREATE NONCLUSTERED INDEX [FKIX_CustomerBillingStatementSetting_IntervalId]
    ON [dbo].[CustomerBillingStatementSetting]([IntervalId] ASC) WITH (FILLFACTOR = 100);


GO

CREATE NONCLUSTERED INDEX [FKIX_CustomerBillingStatementSetting_TypeId]
    ON [dbo].[CustomerBillingStatementSetting]([TypeId] ASC) WITH (FILLFACTOR = 100);


GO

