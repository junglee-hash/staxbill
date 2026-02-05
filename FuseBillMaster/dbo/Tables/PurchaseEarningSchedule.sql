CREATE TABLE [dbo].[PurchaseEarningSchedule] (
    [Id]                        BIGINT         IDENTITY (1, 1) NOT NULL,
    [PurchaseId]                BIGINT         NOT NULL,
    [EarningScheduleIntervalId] INT            NOT NULL,
    [NumberOfIntervals]         INT            NULL,
    [ScheduledAmount]           MONEY          NULL,
    [Reference]                 NVARCHAR (500) NOT NULL,
    [CreatedTimestamp]          DATETIME       NOT NULL,
    [ModifiedTimestamp]         DATETIME       NOT NULL,
    CONSTRAINT [PK_PurchaseEarningSchedule] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_PurchaseEarningSchedule_Purchase] FOREIGN KEY ([PurchaseId]) REFERENCES [dbo].[Purchase] ([Id]) ON DELETE CASCADE,
    CONSTRAINT [FK_PurchaseEarningScheduleIntervalId_EarningTimingInterval] FOREIGN KEY ([EarningScheduleIntervalId]) REFERENCES [Lookup].[EarningTimingInterval] ([Id])
);


GO

