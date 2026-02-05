CREATE TABLE [dbo].[CustomerIntegration] (
    [Id]                        BIGINT         IDENTITY (1, 1) NOT NULL,
    [CustomerId]                BIGINT         NOT NULL,
    [CustomerIntegrationTypeId] INT            NOT NULL,
    [IntegrationId]             NVARCHAR (255) NOT NULL,
    [CreatedTimestamp]          DATETIME       NOT NULL,
    [ModifiedTimestamp]         DATETIME       NOT NULL,
    CONSTRAINT [PK_CustomerIntegration] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_CustomerIntegration_Customer] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([Id]),
    CONSTRAINT [FK_CustomerIntegration_CustomerIntegrationType] FOREIGN KEY ([CustomerIntegrationTypeId]) REFERENCES [Lookup].[CustomerIntegrationType] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_CustomerIntegration_CustomerId_CustomerIntegrationTypeId]
    ON [dbo].[CustomerIntegration]([CustomerId] ASC, [CustomerIntegrationTypeId] ASC) WITH (FILLFACTOR = 100);


GO

CREATE NONCLUSTERED INDEX [IX_CustomerIntegration_CustomerId_CustomerIntegrationTypeId_INCL]
    ON [dbo].[CustomerIntegration]([CustomerId] ASC, [CustomerIntegrationTypeId] ASC)
    INCLUDE([IntegrationId]) WITH (FILLFACTOR = 100);


GO

