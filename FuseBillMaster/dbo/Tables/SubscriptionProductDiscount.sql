CREATE TABLE [dbo].[SubscriptionProductDiscount] (
    [Id]                        BIGINT          IDENTITY (1, 1) NOT NULL,
    [SubscriptionProductId]     BIGINT          NOT NULL,
    [DiscountTypeId]            INT             NOT NULL,
    [Amount]                    DECIMAL (18, 6) NOT NULL,
    [RemainingUsage]            INT             NULL,
    [RemainingUsagesUntilStart] INT             NOT NULL,
    [CouponCodeId]              BIGINT          NULL,
    [HasStarted]                BIT             CONSTRAINT [DF_HasStarted] DEFAULT ((0)) NOT NULL,
    [HasFinished]               BIT             CONSTRAINT [DF_HasFinished] DEFAULT ((0)) NOT NULL,
    [ModifiedTimestamp]         DATETIME        NOT NULL,
    [NetsuiteItemId]            VARCHAR (100)   NULL,
    CONSTRAINT [PK_SubscriptionProductDiscount] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_SubscriptionProductDiscount_CouponCode] FOREIGN KEY ([CouponCodeId]) REFERENCES [dbo].[CouponCode] ([Id]),
    CONSTRAINT [FK_SubscriptionProductDiscount_DiscountType] FOREIGN KEY ([DiscountTypeId]) REFERENCES [Lookup].[DiscountType] ([Id]),
    CONSTRAINT [FK_SubscriptionProductDiscount_SubscriptionProduct] FOREIGN KEY ([SubscriptionProductId]) REFERENCES [dbo].[SubscriptionProduct] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_SubscriptionProductDiscount_DiscountTypeId]
    ON [dbo].[SubscriptionProductDiscount]([DiscountTypeId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_SubscriptionProductDiscount_SubscriptionProductId]
    ON [dbo].[SubscriptionProductDiscount]([SubscriptionProductId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_SubscriptionProductDiscount_CouponCodeId]
    ON [dbo].[SubscriptionProductDiscount]([CouponCodeId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

