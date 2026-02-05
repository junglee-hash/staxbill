CREATE TABLE [dbo].[NetsuiteErrorLog] (
    [Id]                    BIGINT         IDENTITY (1, 1) NOT NULL,
    [AccountId]             BIGINT         NOT NULL,
    [EntityTypeId]          INT            NOT NULL,
    [EntityId]              BIGINT         NOT NULL,
    [NetsuiteErrorReasonId] TINYINT        NOT NULL,
    [LastErrorReason]       NVARCHAR (500) NULL,
    [CreatedTimestamp]      DATETIME       NOT NULL,
    [ModifiedTimestamp]     DATETIME       NOT NULL,
    CONSTRAINT [PK_NetsuiteErrorLog] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_NetsuiteErrorLog_AccountId] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id]),
    CONSTRAINT [FK_NetsuiteErrorLog_EntityTypeId] FOREIGN KEY ([EntityTypeId]) REFERENCES [Lookup].[EntityType] ([Id]),
    CONSTRAINT [FK_NetsuiteErrorLog_NetsuiteErrorReasonId] FOREIGN KEY ([NetsuiteErrorReasonId]) REFERENCES [Lookup].[NetsuiteErrorReason] ([Id])
);


GO

CREATE UNIQUE NONCLUSTERED INDEX [UX_NetsuiteErrorLog, EntityId, EntityTypeId]
    ON [dbo].[NetsuiteErrorLog]([EntityId] ASC, [EntityTypeId] ASC) WITH (FILLFACTOR = 80);


GO

CREATE NONCLUSTERED INDEX [IX_NetsuiteErrorLog_AccountId_EntityId_EntityTypeId_NetsuiteErrorReasonId]
    ON [dbo].[NetsuiteErrorLog]([AccountId] ASC, [EntityId] ASC, [EntityTypeId] ASC, [NetsuiteErrorReasonId] ASC) WITH (FILLFACTOR = 100);


GO

