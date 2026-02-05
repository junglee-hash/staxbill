CREATE TABLE [dbo].[PurchaseDiscount] (
    [Id]             BIGINT          IDENTITY (1, 1) NOT NULL,
    [PurchaseId]     BIGINT          NOT NULL,
    [DiscountTypeId] INT             NOT NULL,
    [Amount]         DECIMAL (18, 6) NOT NULL,
    [CouponCodeId]   BIGINT          NULL,
    [NetsuiteItemId] VARCHAR (100)   NULL,
    CONSTRAINT [PK_PurchaseDiscount] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_PurchaseDiscount_CouponCode] FOREIGN KEY ([CouponCodeId]) REFERENCES [dbo].[CouponCode] ([Id]),
    CONSTRAINT [FK_PurchaseDiscount_DiscountType] FOREIGN KEY ([DiscountTypeId]) REFERENCES [Lookup].[DiscountType] ([Id]),
    CONSTRAINT [FK_PurchaseDiscount_Purchase] FOREIGN KEY ([PurchaseId]) REFERENCES [dbo].[Purchase] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_PurchaseDiscount_PurchaseId]
    ON [dbo].[PurchaseDiscount]([PurchaseId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_PurchaseDiscount_CouponCodeId]
    ON [dbo].[PurchaseDiscount]([CouponCodeId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_PurchaseDiscount_DiscountTypeId]
    ON [dbo].[PurchaseDiscount]([DiscountTypeId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

