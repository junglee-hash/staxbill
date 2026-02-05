CREATE TABLE [dbo].[AccountBillingStatementPreference] (
    [Id]                                  BIGINT         NOT NULL,
    [OptionId]                            INT            NOT NULL,
    [TypeId]                              INT            NULL,
    [IntervalId]                          INT            NULL,
    [Day]                                 INT            NULL,
    [Month]                               INT            NULL,
    [ShowTrackedItemName]                 BIT            DEFAULT ((0)) NOT NULL,
    [ShowTrackedItemReference]            BIT            DEFAULT ((0)) NOT NULL,
    [ShowTrackedItemDescription]          BIT            DEFAULT ((0)) NOT NULL,
    [TrackedItemDisplayFormatId]          INT            NULL,
    [ShowTrackedItemCreatedDate]          BIT            CONSTRAINT [DF_ShowTrackedItemCreatedDate_AccountBillingStatementPreference] DEFAULT ((0)) NOT NULL,
    [TrackedItemNameFieldOverride]        NVARCHAR (100) NULL,
    [TrackedItemReferenceFieldOverride]   NVARCHAR (100) NULL,
    [TrackedItemDescriptionFieldOverride] NVARCHAR (100) NULL,
    [TrackedItemCreatedDateFieldOverride] NVARCHAR (100) NULL,
    [TrackedItemPageLabelOverride]        NVARCHAR (100) NULL,
    [TrackedItemMainInvoiceMessage]       NVARCHAR (500) NULL,
    [StatementActivityTypeId]             INT            CONSTRAINT [DF_AccountBillingStatementPreference_StatementActivityType] DEFAULT ((1)) NOT NULL,
    [ShowWordStatement]                   BIT            DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_AccountBillingStatementPreference] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_AccountBillingStatementPreference_Account] FOREIGN KEY ([Id]) REFERENCES [dbo].[Account] ([Id]),
    CONSTRAINT [FK_AccountBillingStatementPreference_BillingStatementOption] FOREIGN KEY ([OptionId]) REFERENCES [Lookup].[BillingStatementOption] ([Id]),
    CONSTRAINT [FK_AccountBillingStatementPreference_BillingStatementType] FOREIGN KEY ([TypeId]) REFERENCES [Lookup].[BillingStatementType] ([Id]),
    CONSTRAINT [FK_AccountBillingStatementPreference_Interval] FOREIGN KEY ([IntervalId]) REFERENCES [Lookup].[Interval] ([Id]),
    CONSTRAINT [FK_AccountBillingStatementPreference_StatementActivityType] FOREIGN KEY ([StatementActivityTypeId]) REFERENCES [Lookup].[StatementActivityType] ([Id]),
    CONSTRAINT [FK_AccountBillingStatementPreference_TrackedItemDisplayFormat] FOREIGN KEY ([TrackedItemDisplayFormatId]) REFERENCES [Lookup].[TrackedItemDisplayFormat] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_AccountBillingStatementPreference_TrackedItemDisplayFormatId]
    ON [dbo].[AccountBillingStatementPreference]([TrackedItemDisplayFormatId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_AccountBillingStatementPreference_IntervalId]
    ON [dbo].[AccountBillingStatementPreference]([IntervalId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_AccountBillingStatementPreference_TypeId]
    ON [dbo].[AccountBillingStatementPreference]([TypeId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_AccountBillingStatementPreference_OptionId]
    ON [dbo].[AccountBillingStatementPreference]([OptionId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

