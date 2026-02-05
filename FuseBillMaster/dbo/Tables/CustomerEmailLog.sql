CREATE TABLE [dbo].[CustomerEmailLog] (
    [Id]                 BIGINT         IDENTITY (1, 1) NOT NULL,
    [CustomerId]         BIGINT         NOT NULL,
    [Subject]            VARCHAR (255)  NOT NULL,
    [Body]               NVARCHAR (MAX) NOT NULL,
    [AttachmentIncluded] BIT            NOT NULL,
    [EffectiveTimestamp] DATETIME       NULL,
    [CreatedTimestamp]   DATETIME       NOT NULL,
    [ToEmail]            VARCHAR (255)  NULL,
    [BccEmail]           VARCHAR (255)  NULL,
    [ToDisplayName]      VARCHAR (255)  NULL,
    [BccDisplayName]     VARCHAR (255)  NULL,
    [FromEmail]          VARCHAR (255)  NULL,
    [FromDisplayName]    VARCHAR (255)  NULL,
    [StatusId]           INT            NOT NULL,
    [Result]             NVARCHAR (500) NULL,
    [SendgridEmailId]    NVARCHAR (255) NULL,
    [EmailTypeId]        INT            NULL,
    [AccountId]          BIGINT         NOT NULL,
    [CreatedYear]        AS             (datepart(year,[CreatedTimestamp])),
    [CreatedMonth]       AS             (datepart(month,[CreatedTimestamp])),
    CONSTRAINT [PK_EmailCommunicationLog] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CustomerEmailLog_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id]),
    CONSTRAINT [FK_CustomerEmailLog_EmailStatus] FOREIGN KEY ([StatusId]) REFERENCES [Lookup].[EmailStatus] ([Id]),
    CONSTRAINT [FK_CustomerEmailLog_EmailTypeId] FOREIGN KEY ([EmailTypeId]) REFERENCES [Lookup].[EmailType] ([Id]),
    CONSTRAINT [FK_EmailCommunicationLog_Customer] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_CustomerEmailLog_CreatedTimestamp_YearMonth]
    ON [dbo].[CustomerEmailLog]([CreatedYear] ASC, [CreatedMonth] ASC)
    INCLUDE([Id], [AccountId], [CustomerId], [CreatedTimestamp]);


GO

CREATE NONCLUSTERED INDEX [IX_CustomerEmailLog_CustomerId]
    ON [dbo].[CustomerEmailLog]([CustomerId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_CustomerEmailLog_StatusId]
    ON [dbo].[CustomerEmailLog]([StatusId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_CustomerEmailLog_SendgridEmailId]
    ON [dbo].[CustomerEmailLog]([SendgridEmailId] ASC) WITH (FILLFACTOR = 100);


GO

