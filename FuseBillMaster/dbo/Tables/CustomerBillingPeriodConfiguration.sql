CREATE TABLE [dbo].[CustomerBillingPeriodConfiguration] (
    [Id]                       BIGINT   IDENTITY (1, 1) NOT NULL,
    [CustomerBillingSettingId] BIGINT   NOT NULL,
    [IntervalId]               INT      NOT NULL,
    [Month]                    INT      NULL,
    [Day]                      INT      NULL,
    [TypeId]                   INT      NOT NULL,
    [RuleId]                   INT      NOT NULL,
    [CreatedTimestamp]         DATETIME NOT NULL,
    [ModifiedTimestamp]        DATETIME NOT NULL,
    [Weekday]                  INT      NULL,
    CONSTRAINT [PK_CustomerBillingPeriodConfiguration] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CustomerBillingPeriodConfiguration_BillingPeriodRule] FOREIGN KEY ([RuleId]) REFERENCES [Lookup].[BillingPeriodRule] ([Id]),
    CONSTRAINT [FK_CustomerBillingPeriodConfiguration_BillingPeriodType] FOREIGN KEY ([TypeId]) REFERENCES [Lookup].[BillingPeriodType] ([Id]),
    CONSTRAINT [FK_CustomerBillingPeriodConfiguration_CustomerBillingSetting] FOREIGN KEY ([CustomerBillingSettingId]) REFERENCES [dbo].[CustomerBillingSetting] ([Id]),
    CONSTRAINT [FK_CustomerBillingPeriodConfiguration_Interval] FOREIGN KEY ([IntervalId]) REFERENCES [Lookup].[Interval] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_CustomerBillingPeriodConfiguration_CustomerBillingSettingId]
    ON [dbo].[CustomerBillingPeriodConfiguration]([CustomerBillingSettingId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_CustomerBillingPeriodConfiguration_TypeId]
    ON [dbo].[CustomerBillingPeriodConfiguration]([TypeId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_CustomerBillingPeriodConfiguration_IntervalId]
    ON [dbo].[CustomerBillingPeriodConfiguration]([IntervalId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_CustomerBillingPeriodConfiguration_RuleId]
    ON [dbo].[CustomerBillingPeriodConfiguration]([RuleId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

