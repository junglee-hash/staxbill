CREATE TABLE [dbo].[IntegrationSynchJob] (
    [Id]                  BIGINT         IDENTITY (1, 1) NOT NULL,
    [AccountId]           BIGINT         NOT NULL,
    [ApiVersion]          VARCHAR (10)   NULL,
    [ExternalJobId]       NVARCHAR (255) NULL,
    [EntityTypeId]        INT            NOT NULL,
    [StartTimestamp]      DATETIME       NULL,
    [RequestStatusId]     INT            NOT NULL,
    [ResponseStatusId]    INT            NULL,
    [ParentJobId]         BIGINT         NULL,
    [LastPolledTimestamp] DATETIME       NULL,
    [CreatedTimestamp]    DATETIME       NOT NULL,
    [ModifiedTimestamp]   DATETIME       NOT NULL,
    [Operation]           VARCHAR (10)   NOT NULL,
    [IntegrationTypeId]   INT            NOT NULL,
    [UseFusebillIds]      BIT            CONSTRAINT [DF_UseFusebillIds] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_IntegrationSynchJob] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_IntegrationSynchJob_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id]),
    CONSTRAINT [FK_IntegrationSynchJob_EntityType] FOREIGN KEY ([EntityTypeId]) REFERENCES [Lookup].[EntityType] ([Id]),
    CONSTRAINT [FK_IntegrationSynchJob_IntegrationSynchJob] FOREIGN KEY ([ParentJobId]) REFERENCES [dbo].[IntegrationSynchJob] ([Id]),
    CONSTRAINT [FK_IntegrationSynchJob_IntegrationSynchJobRequestStatus] FOREIGN KEY ([RequestStatusId]) REFERENCES [Lookup].[IntegrationSynchJobRequestStatus] ([Id]),
    CONSTRAINT [FK_IntegrationSynchJob_IntegrationSynchJobResponseStatus] FOREIGN KEY ([ResponseStatusId]) REFERENCES [Lookup].[IntegrationSynchJobResponseStatus] ([Id]),
    CONSTRAINT [FK_IntegrationSynchJob_IntegrationType] FOREIGN KEY ([IntegrationTypeId]) REFERENCES [Lookup].[IntegrationType] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_IntegrationSynchJob_RequestStatusId]
    ON [dbo].[IntegrationSynchJob]([RequestStatusId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_IntegrationSynchJob_IntegrationTypeId]
    ON [dbo].[IntegrationSynchJob]([IntegrationTypeId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_IntegrationSynchJob_AccountId]
    ON [dbo].[IntegrationSynchJob]([AccountId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_IntegrationSynchJob_ResponseStatusId]
    ON [dbo].[IntegrationSynchJob]([ResponseStatusId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_IntegrationSynchJob_ParentJobId]
    ON [dbo].[IntegrationSynchJob]([ParentJobId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_IntegrationSynchJob_EntityTypeId]
    ON [dbo].[IntegrationSynchJob]([EntityTypeId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

