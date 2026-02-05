CREATE TABLE [dbo].[IntegrationSynchBatchRecord] (
    [Id]                      BIGINT         IDENTITY (1, 1) NOT NULL,
    [IntegrationSynchBatchId] BIGINT         NOT NULL,
    [EntityTypeId]            INT            NOT NULL,
    [EntityId]                BIGINT         NOT NULL,
    [ExternalId]              NVARCHAR (255) NULL,
    [StatusId]                INT            NULL,
    [FailureReason]           NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_IntegrationSynchBatchRecord] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_IntegrationSynchBatchRecord_EntityType] FOREIGN KEY ([EntityTypeId]) REFERENCES [Lookup].[EntityType] ([Id]),
    CONSTRAINT [FK_IntegrationSynchBatchRecord_IntegrationSynchBatch] FOREIGN KEY ([IntegrationSynchBatchId]) REFERENCES [dbo].[IntegrationSynchBatch] ([Id]),
    CONSTRAINT [FK_IntegrationSynchBatchRecord_IntegrationSynchBatchRecordStatus] FOREIGN KEY ([StatusId]) REFERENCES [Lookup].[IntegrationSynchBatchRecordStatus] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_IntegrationSynchBatchRecord_IntegrationSynchBatchId_EntityId]
    ON [dbo].[IntegrationSynchBatchRecord]([IntegrationSynchBatchId] ASC, [EntityId] ASC) WITH (FILLFACTOR = 100);


GO

CREATE NONCLUSTERED INDEX [IX_IntegrationSynchBatchRecord_IntegrationSynchBatchId_EntityTypeId_EntityId]
    ON [dbo].[IntegrationSynchBatchRecord]([IntegrationSynchBatchId] ASC, [EntityTypeId] ASC, [EntityId] ASC) WITH (FILLFACTOR = 100);


GO

