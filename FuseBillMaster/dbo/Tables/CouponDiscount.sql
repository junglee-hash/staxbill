CREATE TABLE [dbo].[CouponDiscount] (
    [Id]                      BIGINT   IDENTITY (1, 1) NOT NULL,
    [CouponId]                BIGINT   NOT NULL,
    [CreatedTimestamp]        DATETIME NOT NULL,
    [ModifiedTimestamp]       DATETIME NOT NULL,
    [DiscountConfigurationId] BIGINT   NOT NULL,
    [CouponEligibilityId]     BIGINT   NULL,
    CONSTRAINT [PK_CouponDiscount] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    FOREIGN KEY ([CouponEligibilityId]) REFERENCES [dbo].[CouponEligibility] ([Id]),
    CONSTRAINT [FK_CouponDiscount_Coupon] FOREIGN KEY ([CouponId]) REFERENCES [dbo].[Coupon] ([Id]),
    CONSTRAINT [FK_CouponDiscount_DiscountConfiguration] FOREIGN KEY ([DiscountConfigurationId]) REFERENCES [dbo].[DiscountConfiguration] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_CouponDiscount_DiscountConfigurationId]
    ON [dbo].[CouponDiscount]([DiscountConfigurationId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_CouponDiscount_CouponEligibilityId]
    ON [dbo].[CouponDiscount]([CouponEligibilityId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_CouponDiscount_CouponId]
    ON [dbo].[CouponDiscount]([CouponId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

