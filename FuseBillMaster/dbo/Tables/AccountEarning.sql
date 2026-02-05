CREATE TABLE [dbo].[AccountEarning] (
    [Id]                 BIGINT   IDENTITY (1, 1) NOT NULL,
    [AccountId]          BIGINT   NOT NULL,
    [CreatedTimestamp]   DATETIME NOT NULL,
    [TypeId]             TINYINT  NOT NULL,
    [StartTimestamp]     DATETIME NULL,
    [CompletedTimestamp] DATETIME NULL,
    [RecordsCreated]     INT      NULL,
    CONSTRAINT [PK_AccountEarning] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_AccountEarning_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_AccountEarning_AccountId]
    ON [dbo].[AccountEarning]([AccountId] ASC) WITH (FILLFACTOR = 100);


GO

