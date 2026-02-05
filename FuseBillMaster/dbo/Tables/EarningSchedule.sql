CREATE TABLE [dbo].[EarningSchedule] (
    [Id]                    BIGINT         IDENTITY (1, 1) NOT NULL,
    [ChargeId]              BIGINT         NOT NULL,
    [EarningScheduleTypeId] TINYINT        NOT NULL,
    [ScheduledAmount]       MONEY          NULL,
    [ScheduledTimestamp]    DATETIME       NULL,
    [Reference]             NVARCHAR (500) NULL,
    [CreatedTimestamp]      DATETIME       NOT NULL,
    [ModifiedTimestamp]     DATETIME       NOT NULL,
    CONSTRAINT [PK_EarningSchedule] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_EarningSchedule_Charge] FOREIGN KEY ([ChargeId]) REFERENCES [dbo].[Charge] ([Id]),
    CONSTRAINT [FK_EarningSchedule_EarningScheduleType] FOREIGN KEY ([EarningScheduleTypeId]) REFERENCES [Lookup].[​EarningScheduleType] ([Id])
);


GO

