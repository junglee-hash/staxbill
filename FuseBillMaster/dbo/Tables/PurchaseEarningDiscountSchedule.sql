CREATE TABLE [dbo].[PurchaseEarningDiscountSchedule] (
    [Id]                        BIGINT   IDENTITY (1, 1) NOT NULL,
    [PurchaseEarningScheduleId] BIGINT   NOT NULL,
    [ScheduledAmount]           MONEY    NULL,
    [CreatedTimestamp]          DATETIME NOT NULL,
    [ModifiedTimestamp]         DATETIME NOT NULL,
    CONSTRAINT [PK_PurchaseEarningDiscountSchedule] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_PurchaseEarningDiscountSchedule_PurchaseEarningSchedule] FOREIGN KEY ([PurchaseEarningScheduleId]) REFERENCES [dbo].[PurchaseEarningSchedule] ([Id]) ON DELETE CASCADE
);


GO

