CREATE TABLE [dbo].[CollectionScheduleActivity] (
    [Id]               BIGINT   IDENTITY (1, 1) NOT NULL,
    [DayAttempted]     INT      NOT NULL,
    [CreatedTimestamp] DATETIME NOT NULL,
    [CustomerId]       BIGINT   NOT NULL,
    CONSTRAINT [pk_CollectionScheduleActivity] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CollectionScheduleActivity_Customer] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_CollectionScheduleActivity_CustomerId]
    ON [dbo].[CollectionScheduleActivity]([CustomerId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

