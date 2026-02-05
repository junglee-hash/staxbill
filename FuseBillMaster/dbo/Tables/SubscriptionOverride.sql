CREATE TABLE [dbo].[SubscriptionOverride] (
    [Id]                BIGINT         NOT NULL,
    [CreatedTimestamp]  DATETIME       NOT NULL,
    [ModifiedTimestamp] DATETIME       NOT NULL,
    [Name]              NVARCHAR (100) NULL,
    [Description]       NVARCHAR (500) NULL,
    CONSTRAINT [PK_SubscriptionRevision] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_SubscriptionOverride_Id] FOREIGN KEY ([Id]) REFERENCES [dbo].[Subscription] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_SubscriptionOverride_ModifiedTimestamp]
    ON [dbo].[SubscriptionOverride]([ModifiedTimestamp] ASC) WITH (FILLFACTOR = 100);


GO

