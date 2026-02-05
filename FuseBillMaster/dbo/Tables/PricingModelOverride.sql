CREATE TABLE [dbo].[PricingModelOverride] (
    [Id]                 BIGINT   NOT NULL,
    [CreatedTimestamp]   DATETIME NOT NULL,
    [ModifiedTimestamp]  DATETIME NOT NULL,
    [PricingModelTypeId] INT      NOT NULL,
    CONSTRAINT [PK_PricingModelOverride] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_PricingModelOverride_PricingModelType] FOREIGN KEY ([PricingModelTypeId]) REFERENCES [Lookup].[PricingModelType] ([Id]),
    CONSTRAINT [FK_PricingModelOverride_SubscriptionProduct1] FOREIGN KEY ([Id]) REFERENCES [dbo].[SubscriptionProduct] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_PricingModelOverride_PricingModelTypeId]
    ON [dbo].[PricingModelOverride]([PricingModelTypeId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_PricingModelOverride_ModifiedTimestamp]
    ON [dbo].[PricingModelOverride]([ModifiedTimestamp] ASC) WITH (FILLFACTOR = 100);


GO

