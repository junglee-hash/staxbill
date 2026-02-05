CREATE TABLE [dbo].[AccountBillingPeriodConfiguration] (
    [Id]                         BIGINT   IDENTITY (1, 1) NOT NULL,
    [AccountBillingPreferenceId] BIGINT   NOT NULL,
    [IntervalId]                 INT      NOT NULL,
    [Month]                      INT      NULL,
    [Day]                        INT      NULL,
    [TypeId]                     INT      NOT NULL,
    [RuleId]                     INT      NOT NULL,
    [CreatedTimestamp]           DATETIME NOT NULL,
    [ModifiedTimestamp]          DATETIME NOT NULL,
    [Weekday]                    INT      NULL,
    CONSTRAINT [PK_AccountBillingPeriodConfiguration] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_AccountBillingPeriodConfiguration_AccountBillingPreference] FOREIGN KEY ([AccountBillingPreferenceId]) REFERENCES [dbo].[AccountBillingPreference] ([Id]),
    CONSTRAINT [FK_AccountBillingPeriodConfiguration_BillingPeriodRule] FOREIGN KEY ([RuleId]) REFERENCES [Lookup].[BillingPeriodRule] ([Id]),
    CONSTRAINT [FK_AccountBillingPeriodConfiguration_BillingPeriodType] FOREIGN KEY ([TypeId]) REFERENCES [Lookup].[BillingPeriodType] ([Id]),
    CONSTRAINT [FK_AccountBillingPeriodConfiguration_Interval] FOREIGN KEY ([IntervalId]) REFERENCES [Lookup].[Interval] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_AccountBillingPeriodConfiguration_IntervalId]
    ON [dbo].[AccountBillingPeriodConfiguration]([IntervalId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_AccountBillingPeriodConfiguration_RuleId]
    ON [dbo].[AccountBillingPeriodConfiguration]([RuleId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_AccountBillingPeriodConfiguration_AccountBillingPreferenceId]
    ON [dbo].[AccountBillingPeriodConfiguration]([AccountBillingPreferenceId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_AccountBillingPeriodConfiguration_TypeId]
    ON [dbo].[AccountBillingPeriodConfiguration]([TypeId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

