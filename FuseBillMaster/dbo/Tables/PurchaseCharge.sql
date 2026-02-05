CREATE TABLE [dbo].[PurchaseCharge] (
    [Id]               BIGINT   NOT NULL,
    [PurchaseId]       BIGINT   NOT NULL,
    [CreatedTimestamp] DATETIME NOT NULL,
    CONSTRAINT [PK_PurchaseCharge] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_PurchaseCharge_Charge] FOREIGN KEY ([Id]) REFERENCES [dbo].[Charge] ([Id]),
    CONSTRAINT [FK_PurchaseCharge_Purchase] FOREIGN KEY ([PurchaseId]) REFERENCES [dbo].[Purchase] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_PurchaseCharge_PurchaseId]
    ON [dbo].[PurchaseCharge]([PurchaseId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

