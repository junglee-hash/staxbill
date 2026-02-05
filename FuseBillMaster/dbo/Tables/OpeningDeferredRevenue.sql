CREATE TABLE [dbo].[OpeningDeferredRevenue] (
    [Id]                        BIGINT   NOT NULL,
    [EarningStartDate]          DATETIME NOT NULL,
    [EarningEndDate]            DATETIME NOT NULL,
    [EarningTimingTypeId]       INT      NOT NULL,
    [EarningTimingIntervalId]   INT      NOT NULL,
    [GlCodeId]                  BIGINT   NULL,
    [NextEarningTimestamp]      DATETIME NOT NULL,
    [CompletedEarningTimestamp] DATETIME NULL,
    CONSTRAINT [PK_OpeningDeferredRevenue] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_OpeningDeferredRevenue_GLCode] FOREIGN KEY ([GlCodeId]) REFERENCES [dbo].[GLCode] ([Id]),
    CONSTRAINT [FK_OpeningDeferredRevenue_Transaction] FOREIGN KEY ([Id]) REFERENCES [dbo].[Transaction] ([Id]),
    CONSTRAINT [FK_OpeningDeferredRevenueEarningTimingIntervalId_EarningTimingInterval] FOREIGN KEY ([EarningTimingIntervalId]) REFERENCES [Lookup].[EarningTimingInterval] ([Id]),
    CONSTRAINT [FK_OpeningDeferredRevenueEarningTimingTypeId_EarningTimingType] FOREIGN KEY ([EarningTimingTypeId]) REFERENCES [Lookup].[EarningTimingType] ([Id])
);


GO

