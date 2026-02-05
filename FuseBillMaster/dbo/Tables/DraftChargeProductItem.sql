CREATE TABLE [dbo].[DraftChargeProductItem] (
    [Id]            BIGINT         IDENTITY (1, 1) NOT NULL,
    [DraftChargeId] BIGINT         NOT NULL,
    [ProductItemId] BIGINT         NOT NULL,
    [Name]          NVARCHAR (100) NULL,
    [Reference]     NVARCHAR (255) NOT NULL,
    [Description]   VARCHAR (255)  NULL,
    CONSTRAINT [PK_DraftChargeSubscriptionProductItem] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_DraftChargeProductItem_DraftCharge] FOREIGN KEY ([DraftChargeId]) REFERENCES [dbo].[DraftCharge] ([Id]),
    CONSTRAINT [FK_DraftChargeProductItem_ProductItem] FOREIGN KEY ([ProductItemId]) REFERENCES [dbo].[ProductItem] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_DraftChargeSubscriptionProductItem_DraftChargeId_IncProductItem]
    ON [dbo].[DraftChargeProductItem]([DraftChargeId] ASC)
    INCLUDE([ProductItemId]) WITH (FILLFACTOR = 100);


GO

CREATE NONCLUSTERED INDEX [FKIX_DraftChargeSubscriptionProductItem_SubscriptionProductItemId]
    ON [dbo].[DraftChargeProductItem]([ProductItemId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

