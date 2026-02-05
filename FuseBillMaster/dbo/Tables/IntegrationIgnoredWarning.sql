CREATE TABLE [dbo].[IntegrationIgnoredWarning] (
    [Id]                 BIGINT         IDENTITY (1, 1) NOT NULL,
    [AccountId]          BIGINT         NOT NULL,
    [IntegrationTypeId]  INT            NOT NULL,
    [EntityTypeId]       INT            NOT NULL,
    [EntityId]           BIGINT         NOT NULL,
    [UserId]             BIGINT         NOT NULL,
    [Details]            NVARCHAR (255) NOT NULL,
    [EffectiveTimestamp] DATETIME       NOT NULL,
    [CreatedTimestamp]   DATETIME       NOT NULL,
    [ModifiedTimestamp]  DATETIME       NOT NULL,
    CONSTRAINT [PK_IntegrationIgnoredWarning] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_IntegrationIgnoredWarning_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id]),
    CONSTRAINT [FK_IntegrationIgnoredWarning_EntityType] FOREIGN KEY ([EntityTypeId]) REFERENCES [Lookup].[EntityType] ([Id]),
    CONSTRAINT [FK_IntegrationIgnoredWarning_IntegrationType] FOREIGN KEY ([IntegrationTypeId]) REFERENCES [Lookup].[IntegrationType] ([Id]),
    CONSTRAINT [FK_IntegrationIgnoredWarning_User] FOREIGN KEY ([UserId]) REFERENCES [dbo].[User] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_IntegrationIgnoredWarning_AccountId]
    ON [dbo].[IntegrationIgnoredWarning]([AccountId] ASC) WITH (FILLFACTOR = 100);


GO

