CREATE TABLE [dbo].[BillingPeriod] (
    [Id]                        BIGINT   IDENTITY (1, 1) NOT NULL,
    [CreatedTimestamp]          DATETIME NOT NULL,
    [ModifiedTimestamp]         DATETIME NOT NULL,
    [CustomerId]                BIGINT   NOT NULL,
    [StartDate]                 DATETIME NOT NULL,
    [EndDate]                   DATETIME NOT NULL,
    [PeriodStatusId]            INT      NOT NULL,
    [BillingPeriodDefinitionId] BIGINT   NOT NULL,
    [RechargeDate]              DATETIME NOT NULL,
    CONSTRAINT [PK_BillingPeriod] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_BillingPeriod_BillingPeriodDefinition] FOREIGN KEY ([BillingPeriodDefinitionId]) REFERENCES [dbo].[BillingPeriodDefinition] ([Id]),
    CONSTRAINT [FK_BillingPeriod_Customer] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([Id]),
    CONSTRAINT [FK_BillingPeriod_PeriodStatus] FOREIGN KEY ([PeriodStatusId]) REFERENCES [Lookup].[PeriodStatus] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_BillingPeriod_BillingPeriodDefinitionId]
    ON [dbo].[BillingPeriod]([BillingPeriodDefinitionId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_BillingPeriod_CustomerId_PeriodStatusId_RechargeDate]
    ON [dbo].[BillingPeriod]([CustomerId] ASC, [PeriodStatusId] ASC, [RechargeDate] ASC) WITH (FILLFACTOR = 100);


GO

CREATE NONCLUSTERED INDEX [IX_BillingPeriod_PeriodStatusId_RechargeDate_INCL]
    ON [dbo].[BillingPeriod]([PeriodStatusId] ASC, [RechargeDate] ASC)
    INCLUDE([CustomerId], [EndDate], [BillingPeriodDefinitionId]) WITH (FILLFACTOR = 100);


GO

