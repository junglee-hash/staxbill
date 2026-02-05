CREATE TABLE [dbo].[AccountEmailTemplateContent] (
    [Id]                 BIGINT         IDENTITY (1, 1) NOT NULL,
    [TemplateId]         BIGINT         NOT NULL,
    [TemplateName]       VARCHAR (255)  NOT NULL,
    [MarkDownBody]       NVARCHAR (MAX) NOT NULL,
    [MarkDownSubject]    NVARCHAR (255) NOT NULL,
    [IsAlternateVersion] BIT            CONSTRAINT [DF_IsAlternateVersion] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_AccountEmailTemplateContent] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_AccountEmailTemplateContent_AccountEmailTemplate] FOREIGN KEY ([TemplateId]) REFERENCES [dbo].[AccountEmailTemplate] ([Id])
);


GO

