CREATE TABLE [dbo].[ExternalApiLog] (
    [Id]                 BIGINT          IDENTITY (1, 1) NOT NULL,
    [LogType]            TINYINT         NOT NULL,
    [AccountId]          BIGINT          NULL,
    [Input]              NVARCHAR (4000) NOT NULL,
    [Output]             NVARCHAR (4000) NULL,
    [Message]            NVARCHAR (200)  NULL,
    [InternalEntityId]   BIGINT          NOT NULL,
    [InternalEntityType] INT             NOT NULL,
    [ExternalEntityId]   VARCHAR (50)    NULL,
    [ExternalEntityType] VARCHAR (50)    NULL,
    [CreatedTimestamp]   DATETIME        NOT NULL,
    CONSTRAINT [PK_ExternalApiLog] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_ExternalApiLog_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id]),
    CONSTRAINT [FK_ExternalApiLog_EntityType] FOREIGN KEY ([InternalEntityType]) REFERENCES [Lookup].[EntityType] ([Id]),
    CONSTRAINT [FK_ExternalApiLog_ExternalApiLogType] FOREIGN KEY ([LogType]) REFERENCES [Lookup].[ExternalApiLogType] ([Id])
);


GO

