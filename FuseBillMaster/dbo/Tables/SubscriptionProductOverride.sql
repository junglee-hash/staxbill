CREATE TABLE [dbo].[SubscriptionProductOverride] (
    [Id]                BIGINT         NOT NULL,
    [Name]              NVARCHAR (100) NULL,
    [Description]       NVARCHAR (500) NULL,
    [CreatedTimestamp]  DATETIME       NOT NULL,
    [ModifiedTimestamp] DATETIME       NOT NULL,
    CONSTRAINT [PK_SubscriptionProductOverride] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_SubscriptionProductOverride_SubscriptionProduct1] FOREIGN KEY ([Id]) REFERENCES [dbo].[SubscriptionProduct] ([Id])
);


GO

