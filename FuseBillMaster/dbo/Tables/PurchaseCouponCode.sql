CREATE TABLE [dbo].[PurchaseCouponCode] (
    [Id]               BIGINT   IDENTITY (1, 1) NOT NULL,
    [PurchaseId]       BIGINT   NOT NULL,
    [CouponCodeId]     BIGINT   NOT NULL,
    [CreatedTimestamp] DATETIME NOT NULL,
    CONSTRAINT [PK_PurchaseCouponCode] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_PurchaseCouponCode_CouponCode] FOREIGN KEY ([CouponCodeId]) REFERENCES [dbo].[CouponCode] ([Id]),
    CONSTRAINT [FK_PurchaseCouponCode_Purchase] FOREIGN KEY ([PurchaseId]) REFERENCES [dbo].[Purchase] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_PurchaseCouponCode_PurchaseId]
    ON [dbo].[PurchaseCouponCode]([PurchaseId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_PurchaseCouponCode_CouponCodeId]
    ON [dbo].[PurchaseCouponCode]([CouponCodeId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

