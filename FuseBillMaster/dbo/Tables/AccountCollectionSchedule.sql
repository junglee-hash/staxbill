CREATE TABLE [dbo].[AccountCollectionSchedule] (
    [Id]        BIGINT IDENTITY (1, 1) NOT NULL,
    [AccountId] BIGINT NOT NULL,
    [Day]       INT    NOT NULL,
    CONSTRAINT [pk_AccountCollectionSchedule] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [fk_AccountCollectionSchedule_AccountId] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id]) ON DELETE CASCADE
);


GO

CREATE NONCLUSTERED INDEX [IX_AccountCollectionSchedule_AccountId]
    ON [dbo].[AccountCollectionSchedule]([AccountId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

