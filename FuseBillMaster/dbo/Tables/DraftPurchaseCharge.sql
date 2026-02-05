CREATE TABLE [dbo].[DraftPurchaseCharge] (
    [Id]         BIGINT NOT NULL,
    [PurchaseId] BIGINT NOT NULL,
    CONSTRAINT [PK_DraftPurchaseCharge] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_DraftPurchaseCharge_DraftCharge] FOREIGN KEY ([Id]) REFERENCES [dbo].[DraftCharge] ([Id]),
    CONSTRAINT [FK_DraftPurchaseCharge_Purchase] FOREIGN KEY ([PurchaseId]) REFERENCES [dbo].[Purchase] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_DraftPurchaseCharge_PurchaseId]
    ON [dbo].[DraftPurchaseCharge]([PurchaseId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

