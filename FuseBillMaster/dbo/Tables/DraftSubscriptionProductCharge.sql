CREATE TABLE [dbo].[DraftSubscriptionProductCharge] (
    [Id]                      BIGINT           NOT NULL,
    [SubscriptionProductId]   BIGINT           NULL,
    [StartServiceDate]        DATETIME         NOT NULL,
    [EndServiceDate]          DATETIME         NOT NULL,
    [BillingPeriodId]         BIGINT           NOT NULL,
    [StartServiceDateLabel]   DATETIME         NOT NULL,
    [EndServiceDateLabel]     DATETIME         NOT NULL,
    [DraftChargeGroupName]    VARCHAR (255)    NULL,
    [DraftChargeGroupGuid]    UNIQUEIDENTIFIER NULL,
    [SubscriptionDescription] NVARCHAR (1000)  NULL,
    [SubscriptionReference]   NVARCHAR (255)   NULL,
    [ScheduledMigrationId]    BIGINT           NULL,
    CONSTRAINT [PK_DraftSubscriptionProductCharge] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_DraftSubscriptionProductCharge_BillingPeriod] FOREIGN KEY ([BillingPeriodId]) REFERENCES [dbo].[BillingPeriod] ([Id]),
    CONSTRAINT [FK_DraftSubscriptionProductCharge_DraftCharge] FOREIGN KEY ([Id]) REFERENCES [dbo].[DraftCharge] ([Id]) ON DELETE CASCADE,
    CONSTRAINT [FK_DraftSubscriptionProductCharge_ScheduledMigration] FOREIGN KEY ([ScheduledMigrationId]) REFERENCES [dbo].[ScheduledMigration] ([Id]),
    CONSTRAINT [FK_DraftSubscriptionProductCharge_SubscriptionProduct] FOREIGN KEY ([SubscriptionProductId]) REFERENCES [dbo].[SubscriptionProduct] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_DraftSubscriptionProductCharge_ScheduledMigrationId]
    ON [dbo].[DraftSubscriptionProductCharge]([ScheduledMigrationId] ASC) WITH (FILLFACTOR = 100);


GO

CREATE NONCLUSTERED INDEX [FKIX_DraftSubscriptionProductCharge_SubscriptionProductId]
    ON [dbo].[DraftSubscriptionProductCharge]([SubscriptionProductId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_DraftSubscriptionProductCharge_BillingPeriodId]
    ON [dbo].[DraftSubscriptionProductCharge]([BillingPeriodId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

