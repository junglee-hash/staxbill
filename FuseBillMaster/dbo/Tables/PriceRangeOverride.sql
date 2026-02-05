CREATE TABLE [dbo].[PriceRangeOverride] (
    [Id]                     BIGINT          IDENTITY (1, 1) NOT NULL,
    [PricingModelOverrideId] BIGINT          NOT NULL,
    [Min]                    DECIMAL (18, 6) NOT NULL,
    [Max]                    DECIMAL (18, 6) NULL,
    [Price]                  DECIMAL (18, 6) NOT NULL,
    [ModifiedTimestamp]      DATETIME        NOT NULL,
    CONSTRAINT [PK_PriceRangeOverride] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_PriceRangeOverride_PricingModelOverride] FOREIGN KEY ([PricingModelOverrideId]) REFERENCES [dbo].[PricingModelOverride] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_PriceRangeOverride_PricingModelOverrideId]
    ON [dbo].[PriceRangeOverride]([PricingModelOverrideId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

