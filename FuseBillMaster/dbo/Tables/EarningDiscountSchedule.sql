CREATE TABLE [dbo].[EarningDiscountSchedule] (
    [Id]                    BIGINT         IDENTITY (1, 1) NOT NULL,
    [ChargeId]              BIGINT         NOT NULL,
    [EarningScheduleId]     BIGINT         NOT NULL,
    [EarningScheduleTypeId] TINYINT        NOT NULL,
    [ScheduledAmount]       MONEY          NULL,
    [ScheduledTimestamp]    DATETIME       NULL,
    [Reference]             NVARCHAR (500) NULL,
    [CreatedTimestamp]      DATETIME       NOT NULL,
    [ModifiedTimestamp]     DATETIME       NOT NULL,
    CONSTRAINT [PK_EarningDiscountSchedule] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_EarningDiscountSchedule_Charge] FOREIGN KEY ([ChargeId]) REFERENCES [dbo].[Charge] ([Id]),
    CONSTRAINT [FK_EarningDiscountSchedule_EarningSchedule] FOREIGN KEY ([EarningScheduleId]) REFERENCES [dbo].[EarningSchedule] ([Id]) ON DELETE CASCADE,
    CONSTRAINT [FK_EarningDiscountSchedule_EarningScheduleType] FOREIGN KEY ([EarningScheduleTypeId]) REFERENCES [Lookup].[​EarningScheduleType] ([Id])
);


GO

