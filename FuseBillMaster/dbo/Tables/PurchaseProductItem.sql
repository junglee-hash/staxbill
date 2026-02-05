CREATE TABLE [dbo].[PurchaseProductItem] (
    [PurchaseId] BIGINT NOT NULL,
    [Id]         BIGINT NOT NULL,
    CONSTRAINT [PK_PurchaseProductItem] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_PurchaseProductItem_ProductItem] FOREIGN KEY ([Id]) REFERENCES [dbo].[ProductItem] ([Id]),
    CONSTRAINT [FK_PurchaseProductItem_Purchase] FOREIGN KEY ([PurchaseId]) REFERENCES [dbo].[Purchase] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_PurchaseProductItem_PurchaseId]
    ON [dbo].[PurchaseProductItem]([PurchaseId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

