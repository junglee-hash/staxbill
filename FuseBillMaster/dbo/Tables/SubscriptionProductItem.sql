CREATE TABLE [dbo].[SubscriptionProductItem] (
    [SubscriptionProductId]                BIGINT NOT NULL,
    [Id]                                   BIGINT NOT NULL,
    [SubscriptionProductActivityJournalId] BIGINT NULL,
    CONSTRAINT [PK_SubscriptionProductItem] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_SubscriptionProductItem_ProductItem] FOREIGN KEY ([Id]) REFERENCES [dbo].[ProductItem] ([Id]),
    CONSTRAINT [FK_SubscriptionProductItem_SubscriptionProduct] FOREIGN KEY ([SubscriptionProductId]) REFERENCES [dbo].[SubscriptionProduct] ([Id]),
    CONSTRAINT [FK_SubscriptionProductItem_SubscriptionProductActivityJournal] FOREIGN KEY ([SubscriptionProductActivityJournalId]) REFERENCES [dbo].[SubscriptionProductActivityJournal] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_SubscriptionProductItem_SubscriptionProductId]
    ON [dbo].[SubscriptionProductItem]([SubscriptionProductId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

