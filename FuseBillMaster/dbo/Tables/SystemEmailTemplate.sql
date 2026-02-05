CREATE TABLE [dbo].[SystemEmailTemplate] (
    [Id]                       BIGINT         IDENTITY (1, 1) NOT NULL,
    [MarkDownBody]             NVARCHAR (MAX) NOT NULL,
    [MarkDownSubject]          NVARCHAR (255) NOT NULL,
    [FromEmail]                VARCHAR (255)  NOT NULL,
    [ReplyToEmail]             VARCHAR (255)  NOT NULL,
    [FromDisplay]              VARCHAR (255)  NOT NULL,
    [ReplyToDisplay]           VARCHAR (255)  NOT NULL,
    [BccEmail]                 VARCHAR (255)  NOT NULL,
    [TypeId]                   INT            NOT NULL,
    [AccountServiceProviderId] BIGINT         CONSTRAINT [DF_SystemEmailTemplate_AccountServiceProvider] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_SystemEmailTemplate] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_SystemEmailTemplate_AccountServiceProviderId] FOREIGN KEY ([AccountServiceProviderId]) REFERENCES [dbo].[AccountServiceProviderTemplate] ([Id]),
    CONSTRAINT [FK_SystemEmailTemplate_Type] FOREIGN KEY ([TypeId]) REFERENCES [Lookup].[EmailTemplateType] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_SystemEmailTemplate_TypeId]
    ON [dbo].[SystemEmailTemplate]([TypeId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

