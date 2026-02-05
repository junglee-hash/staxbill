CREATE TABLE [dbo].[AccountWebhooksKey] (
    [AccountId]         BIGINT         NOT NULL,
    [WebhooksKey]       NVARCHAR (255) NOT NULL,
    [CreatedTimestamp]  DATETIME       NOT NULL,
    [ModifiedTimestamp] DATETIME       NOT NULL,
    CONSTRAINT [PK_AccountWebhooksKey] PRIMARY KEY CLUSTERED ([AccountId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_AccountWebhooksKey_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_AccountWebhooksKey_WebhooksKey]
    ON [dbo].[AccountWebhooksKey]([WebhooksKey] ASC)
    INCLUDE([AccountId], [CreatedTimestamp], [ModifiedTimestamp]) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

