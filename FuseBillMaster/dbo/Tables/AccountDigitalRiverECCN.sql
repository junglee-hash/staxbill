CREATE TABLE [dbo].[AccountDigitalRiverECCN] (
    [Id]               BIGINT   IDENTITY (1, 1) NOT NULL,
    [AccountId]        BIGINT   NOT NULL,
    [Code]             CHAR (5) NOT NULL,
    [SortOrder]        INT      NOT NULL,
    [CreatedTimestamp] DATETIME NOT NULL,
    CONSTRAINT [PK_AccountDigitalRiverECCN] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_AccountDigitalRiverECCN_AccountId] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id])
);


GO

