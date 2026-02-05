CREATE TABLE [dbo].[SubscriptionProductCharge] (
    [Id]                    BIGINT   NOT NULL,
    [SubscriptionProductId] BIGINT   NOT NULL,
    [StartServiceDate]      DATETIME NOT NULL,
    [EndServiceDate]        DATETIME NOT NULL,
    [BillingPeriodId]       BIGINT   NOT NULL,
    [StartServiceDateLabel] DATETIME NOT NULL,
    [EndServiceDateLabel]   DATETIME NOT NULL,
    CONSTRAINT [PK_SubscriptionProductCharge] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_SubscriptionProductCharge_BillingPeriod] FOREIGN KEY ([BillingPeriodId]) REFERENCES [dbo].[BillingPeriod] ([Id]),
    CONSTRAINT [FK_SubscriptionProductCharge_Charge] FOREIGN KEY ([Id]) REFERENCES [dbo].[Charge] ([Id]),
    CONSTRAINT [FK_SubscriptionProductCharge_SubscriptionProduct] FOREIGN KEY ([SubscriptionProductId]) REFERENCES [dbo].[SubscriptionProduct] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_SubscriptionProductCharge_SubscriptionProductId]
    ON [dbo].[SubscriptionProductCharge]([SubscriptionProductId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_SubscriptionProductCharge_BillingPeriodId]
    ON [dbo].[SubscriptionProductCharge]([BillingPeriodId] ASC)
    INCLUDE([Id], [SubscriptionProductId], [StartServiceDate], [EndServiceDate], [StartServiceDateLabel], [EndServiceDateLabel]) WITH (FILLFACTOR = 100);


GO

