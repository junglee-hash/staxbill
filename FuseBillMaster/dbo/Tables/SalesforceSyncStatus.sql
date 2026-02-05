CREATE TABLE [dbo].[SalesforceSyncStatus] (
    [Id]                BIGINT   IDENTITY (1, 1) NOT NULL,
    [AccountId]         BIGINT   NOT NULL,
    [ParentEntityId]    BIGINT   NULL,
    [EntityId]          BIGINT   NOT NULL,
    [EntityTypeId]      INT      NOT NULL,
    [LastSyncTimestamp] DATETIME NOT NULL,
    [CreatedTimestamp]  DATETIME NOT NULL,
    [ModifiedTimestamp] DATETIME NOT NULL,
    [RetryCount]        TINYINT  DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_SalesforceSyncStatus] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_SalesforceSyncStatus_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id]),
    CONSTRAINT [FK_SalesforceSyncStatus_EntityType] FOREIGN KEY ([EntityTypeId]) REFERENCES [Lookup].[EntityType] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_SalesforceSyncStatus_AccountId]
    ON [dbo].[SalesforceSyncStatus]([AccountId] ASC) WITH (FILLFACTOR = 100);


GO

CREATE NONCLUSTERED INDEX [IX_SalesforceSyncStatus_EntityId_EntityTypeId_LastSyncTimestamp_AccountId]
    ON [dbo].[SalesforceSyncStatus]([EntityId] ASC, [EntityTypeId] ASC, [LastSyncTimestamp] ASC, [AccountId] ASC)
    INCLUDE([Id]) WITH (FILLFACTOR = 100);


GO

CREATE NONCLUSTERED INDEX [IX_SalesforceSyncStatus_EntityTypeId_EntityId_LastSyncTimestamp_INCL]
    ON [dbo].[SalesforceSyncStatus]([EntityTypeId] ASC, [EntityId] ASC, [LastSyncTimestamp] ASC)
    INCLUDE([RetryCount]) WITH (FILLFACTOR = 100);


GO

