CREATE TABLE [dbo].[PlanProductPriceUplift] (
    [Id]                     BIGINT          IDENTITY (1, 1) NOT NULL,
    [PlanOrderToCashCycleId] BIGINT          NOT NULL,
    [SequenceNumber]         INT             NOT NULL,
    [NumberOfIntervals]      INT             NOT NULL,
    [Amount]                 DECIMAL (18, 6) NOT NULL,
    [RepeatForever]          BIT             NOT NULL,
    [CurrencyId]             BIGINT          NOT NULL,
    [UpliftTypeId]           TINYINT         NOT NULL,
    CONSTRAINT [PK_PlanProductPriceUplift] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_PlanProductPriceUplift_Currency] FOREIGN KEY ([CurrencyId]) REFERENCES [Lookup].[Currency] ([Id]),
    CONSTRAINT [FK_PlanProductPriceUplift_PlanOrderToCashCycle] FOREIGN KEY ([PlanOrderToCashCycleId]) REFERENCES [dbo].[PlanOrderToCashCycle] ([Id]),
    CONSTRAINT [FK_PlanProductPriceUplift_UpliftType] FOREIGN KEY ([UpliftTypeId]) REFERENCES [Lookup].[UpliftType] ([Id])
);


GO

