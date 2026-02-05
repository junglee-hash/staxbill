CREATE TABLE [dbo].[ChargeProductItem] (
    [Id]            BIGINT         IDENTITY (1, 1) NOT NULL,
    [ChargeId]      BIGINT         NOT NULL,
    [ProductItemId] BIGINT         NOT NULL,
    [Name]          NVARCHAR (100) NULL,
    [Reference]     NVARCHAR (255) NOT NULL,
    [Description]   VARCHAR (255)  NULL,
    CONSTRAINT [PK_ChargeSubscriptionProductItem] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_ChargeProductItem_Charge] FOREIGN KEY ([ChargeId]) REFERENCES [dbo].[Charge] ([Id]),
    CONSTRAINT [FK_ChargeProductItem_ProductItem] FOREIGN KEY ([ProductItemId]) REFERENCES [dbo].[ProductItem] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_ChargeSubscriptionProductItem_SubscriptionProductItemId]
    ON [dbo].[ChargeProductItem]([ProductItemId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_ChargeSubscriptionProductItem_ChargeId_IncProductItem]
    ON [dbo].[ChargeProductItem]([ChargeId] ASC)
    INCLUDE([ProductItemId]) WITH (FILLFACTOR = 100);


GO

