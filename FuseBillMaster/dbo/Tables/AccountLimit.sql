CREATE TABLE [dbo].[AccountLimit] (
    [Id]                BIGINT   IDENTITY (1, 1) NOT NULL,
    [AccountId]         BIGINT   NOT NULL,
    [EntityTypeId]      INT      NOT NULL,
    [Limit]             BIGINT   NULL,
    [ModifiedTimestamp] DATETIME NOT NULL,
    CONSTRAINT [PK_AccountLimit] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_AccountLimit_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id]),
    CONSTRAINT [FK_AccountLimit_EntityTypeId] FOREIGN KEY ([EntityTypeId]) REFERENCES [Lookup].[EntityType] ([Id]),
    CONSTRAINT [UC_AccountLimit_AccountId_EntityTypeId] UNIQUE NONCLUSTERED ([AccountId] ASC, [EntityTypeId] ASC) WITH (FILLFACTOR = 100)
);


GO

