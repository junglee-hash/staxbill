CREATE TABLE [dbo].[QuickBooksLog] (
    [Id]               BIGINT         IDENTITY (1, 1) NOT NULL,
    [AccountId]        BIGINT         NOT NULL,
    [CustomerId]       BIGINT         NULL,
    [Input]            NVARCHAR (MAX) NOT NULL,
    [Output]           NVARCHAR (MAX) NOT NULL,
    [FailureReason]    NVARCHAR (500) NOT NULL,
    [Success]          BIT            NOT NULL,
    [CreatedTimestamp] DATETIME       NOT NULL,
    [TypeId]           INT            NOT NULL,
    [EntityType]       INT            NULL,
    [EntityTypeId]     BIGINT         NULL,
    CONSTRAINT [pk_QuickBooksLog] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [fk_QuickBooksLog_AccountId] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id]),
    CONSTRAINT [fk_QuickBooksLog_CustomerId] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_QuickBooksLog_CustomerId_AccountId]
    ON [dbo].[QuickBooksLog]([CustomerId] ASC, [AccountId] ASC) WITH (FILLFACTOR = 100);


GO

CREATE NONCLUSTERED INDEX [FKIX_QuickBoogsLogs_AccountId]
    ON [dbo].[QuickBooksLog]([AccountId] ASC) WITH (FILLFACTOR = 100);


GO

