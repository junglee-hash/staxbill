CREATE TABLE [dbo].[AccountEmailTemplate] (
    [Id]                  BIGINT        IDENTITY (1, 1) NOT NULL,
    [AccountId]           BIGINT        NOT NULL,
    [TypeId]              INT           NOT NULL,
    [Enabled]             BIT           CONSTRAINT [DF_AccountEmailTemplate_Enabled] DEFAULT ((1)) NOT NULL,
    [FromEmail]           VARCHAR (255) NULL,
    [ReplyToEmail]        VARCHAR (255) NULL,
    [FromDisplay]         VARCHAR (255) NULL,
    [ReplyToDisplay]      VARCHAR (255) NULL,
    [BccEmail]            VARCHAR (255) NULL,
    [IncludeAttachment]   BIT           DEFAULT ((1)) NOT NULL,
    [Send0DollarInvoices] BIT           DEFAULT ((1)) NOT NULL,
    [EmailCategoryId]     INT           NOT NULL,
    [ModifiedTimestamp]   DATETIME      NOT NULL,
    [Option1]             BIT           CONSTRAINT [df_AccountEmailTemplate_Option1] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_AccountEmailTemplate] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_AccountEmailTemplate_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id]),
    CONSTRAINT [FK_AccountEmailTemplate_EmailCategory] FOREIGN KEY ([EmailCategoryId]) REFERENCES [Lookup].[EmailCategory] ([Id]),
    CONSTRAINT [FK_AccountEmailTemplate_Type] FOREIGN KEY ([TypeId]) REFERENCES [Lookup].[EmailTemplateType] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_AccountEmailTemplate_TypeId]
    ON [dbo].[AccountEmailTemplate]([TypeId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_AccountEmailTemplate_AccountId]
    ON [dbo].[AccountEmailTemplate]([AccountId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

