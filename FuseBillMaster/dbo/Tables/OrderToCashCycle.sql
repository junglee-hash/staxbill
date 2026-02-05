CREATE TABLE [dbo].[OrderToCashCycle] (
    [Id]                      BIGINT   IDENTITY (1, 1) NOT NULL,
    [CreatedTimestamp]        DATETIME NOT NULL,
    [ModifiedTimestamp]       DATETIME NOT NULL,
    [PricingModelTypeId]      INT      NOT NULL,
    [IsEarnedImmediately]     BIT      NOT NULL,
    [EarningInterval]         INT      NULL,
    [EarningNumberOfInterval] INT      NULL,
    [EarningTimingTypeId]     INT      NOT NULL,
    [EarningTimingIntervalId] INT      NOT NULL,
    [PricingFormulaTypeId]    INT      CONSTRAINT [DF_PricingFormulaTypeId] DEFAULT (NULL) NULL,
    CONSTRAINT [PK_OrderToCashCycle] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    FOREIGN KEY ([PricingFormulaTypeId]) REFERENCES [Lookup].[PricingFormulaType] ([Id]),
    CONSTRAINT [FK_OrderToCashCycle_PricingModelType] FOREIGN KEY ([PricingModelTypeId]) REFERENCES [Lookup].[PricingModelType] ([Id]),
    CONSTRAINT [FK_OrderToCashCycleEarningTimingIntervalId_EarningTimingInterval] FOREIGN KEY ([EarningTimingIntervalId]) REFERENCES [Lookup].[EarningTimingInterval] ([Id]),
    CONSTRAINT [FK_OrderToCashCycleEarningTimingTypeId_EarningTimingType] FOREIGN KEY ([EarningTimingTypeId]) REFERENCES [Lookup].[EarningTimingType] ([Id]),
    CONSTRAINT [FK_OrderToCashCycleIntervalId_Interval] FOREIGN KEY ([EarningInterval]) REFERENCES [Lookup].[Interval] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_OrderToCashCycle_EarningInterval]
    ON [dbo].[OrderToCashCycle]([EarningInterval] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_OrderToCashCycle_EarningTimingIntervalId]
    ON [dbo].[OrderToCashCycle]([EarningTimingIntervalId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_OrderToCashCycle_EarningTimingTypeId]
    ON [dbo].[OrderToCashCycle]([EarningTimingTypeId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_OrderToCashCycle_PricingModelTypeId]
    ON [dbo].[OrderToCashCycle]([PricingModelTypeId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

