CREATE TABLE [dbo].[SendgridEvents] (
    [Id]                 BIGINT          IDENTITY (1, 1) NOT NULL,
    [SendgridEmailId]    NVARCHAR (255)  NULL,
    [Event]              NVARCHAR (50)   NULL,
    [Reason]             NVARCHAR (2000) NULL,
    [Response]           NVARCHAR (2000) NULL,
    [Attempt]            INT             NULL,
    [SendgridTimestamp]  DATETIME2 (7)   NOT NULL,
    [CreatedTimestamp]   DATETIME2 (7)   NOT NULL,
    [Email]              VARCHAR (255)   NULL,
    [AccountId]          BIGINT          NULL,
    [CustomerEmailLogId] BIGINT          NULL,
    CONSTRAINT [PK_SendgridEvents] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_SendGridEvent_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id]),
    CONSTRAINT [FK_SendGridEvent_CustomerEmailLog] FOREIGN KEY ([CustomerEmailLogId]) REFERENCES [dbo].[CustomerEmailLog] ([Id])
);


GO
CREATE NONCLUSTERED INDEX [IX_SendgridEvents_SendgridEmailId]
    ON [dbo].[SendgridEvents]([SendgridEmailId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);
GO

