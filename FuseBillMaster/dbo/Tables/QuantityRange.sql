CREATE TABLE [dbo].[QuantityRange] (
    [Id]                 BIGINT          IDENTITY (1, 1) NOT NULL,
    [Min]                DECIMAL (18, 6) NOT NULL,
    [Max]                DECIMAL (18, 6) NULL,
    [CreatedTimestamp]   DATETIME        NOT NULL,
    [ModifiedTimestamp]  DATETIME        NOT NULL,
    [OrderToCashCycleId] BIGINT          NOT NULL,
    CONSTRAINT [PK_PriceRange] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_QuantityRange_OrderToCashCycle] FOREIGN KEY ([OrderToCashCycleId]) REFERENCES [dbo].[OrderToCashCycle] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_QuantityRange_OrderToCashCycleId]
    ON [dbo].[QuantityRange]([OrderToCashCycleId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

