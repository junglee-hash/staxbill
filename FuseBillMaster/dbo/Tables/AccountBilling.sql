CREATE TABLE [dbo].[AccountBilling] (
    [Id]                 BIGINT         IDENTITY (1, 1) NOT NULL,
    [AccountId]          BIGINT         NOT NULL,
    [CreatedTimestamp]   DATETIME       NOT NULL,
    [ModifiedTimestamp]  DATETIME       NOT NULL,
    [CompletedTimestamp] DATETIME       NULL,
    [TotalCustomers]     INT            NULL,
    [CustomersBilled]    INT            NULL,
    [ThreadName]         NVARCHAR (255) NULL,
    [ThreadsInUse]       INT            NULL,
    CONSTRAINT [PK_AccountBilling] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_AccountBilling_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_AccountBilling_CreatedTimestamp]
    ON [dbo].[AccountBilling]([CreatedTimestamp] ASC) WITH (FILLFACTOR = 100);


GO

CREATE UNIQUE NONCLUSTERED INDEX [UX_AccountCompleted]
    ON [dbo].[AccountBilling]([AccountId] ASC, [CompletedTimestamp] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

