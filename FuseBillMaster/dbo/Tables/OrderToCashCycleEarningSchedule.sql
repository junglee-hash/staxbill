CREATE TABLE [dbo].[OrderToCashCycleEarningSchedule] (
    [Id]                 BIGINT         IDENTITY (1, 1) NOT NULL,
    [OrderToCashCycleId] BIGINT         NOT NULL,
    [CurrencyId]         BIGINT         NOT NULL,
    [IntervalId]         INT            NULL,
    [NumberOfIntervals]  INT            NULL,
    [ScheduledAmount]    MONEY          NULL,
    [Reference]          NVARCHAR (500) NOT NULL,
    [CreatedTimestamp]   DATETIME       NOT NULL,
    [ModifiedTimestamp]  DATETIME       NOT NULL,
    CONSTRAINT [PK_OrderToCashCycleEarningSchedule] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_OrderToCashCycleEarningSchedule_Currency] FOREIGN KEY ([CurrencyId]) REFERENCES [Lookup].[Currency] ([Id]),
    CONSTRAINT [FK_OrderToCashCycleEarningSchedule_EarningTimingInterval] FOREIGN KEY ([IntervalId]) REFERENCES [Lookup].[EarningTimingInterval] ([Id]),
    CONSTRAINT [FK_OrderToCashCycleEarningSchedule_OrderToCashCycle] FOREIGN KEY ([OrderToCashCycleId]) REFERENCES [dbo].[OrderToCashCycle] ([Id])
);


GO

