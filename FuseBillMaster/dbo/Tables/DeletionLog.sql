CREATE TABLE [dbo].[DeletionLog] (
    [Id]                BIGINT IDENTITY (1, 1) NOT NULL,
    [EntityId]          BIGINT NOT NULL,
    [DeletionLogTypeId] INT    NOT NULL,
    CONSTRAINT [FK_DeletionLog] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_DeletionLog_DeletionLogTypeId] FOREIGN KEY ([DeletionLogTypeId]) REFERENCES [Lookup].[DeletionLogType] ([Id])
);


GO

