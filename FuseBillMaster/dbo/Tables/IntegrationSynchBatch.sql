CREATE TABLE [dbo].[IntegrationSynchBatch] (
    [Id]                    BIGINT         IDENTITY (1, 1) NOT NULL,
    [ExternalBatchId]       NVARCHAR (255) NULL,
    [IntegrationSynchJobId] BIGINT         NOT NULL,
    [StatusId]              INT            NULL,
    [CreatedTimestamp]      DATETIME       NOT NULL,
    [ModifiedTimestamp]     DATETIME       NOT NULL,
    [RecordsToProcess]      INT            NOT NULL,
    [LastPolledTimestamp]   DATETIME       NULL,
    CONSTRAINT [PK_IntegrationSynchBatch] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_IntegrationSynchBatch_IntegrationSynchBatchStatus] FOREIGN KEY ([StatusId]) REFERENCES [Lookup].[IntegrationSynchBatchStatus] ([Id]),
    CONSTRAINT [FK_IntegrationSynchBatch_IntegrationSynchJob] FOREIGN KEY ([IntegrationSynchJobId]) REFERENCES [dbo].[IntegrationSynchJob] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_IntegrationSynchBatch_StatusId]
    ON [dbo].[IntegrationSynchBatch]([StatusId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_IntegrationSynchBatch_IntegrationSynchJobId]
    ON [dbo].[IntegrationSynchBatch]([IntegrationSynchJobId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

