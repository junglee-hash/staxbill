CREATE TABLE [dbo].[CouponPlan] (
    [Id]                 BIGINT   IDENTITY (1, 1) NOT NULL,
    [CouponId]           BIGINT   NOT NULL,
    [PlanId]             BIGINT   NOT NULL,
    [CreatedTimestamp]   DATETIME NOT NULL,
    [ModifiedTimestamp]  DATETIME NOT NULL,
    [ApplyToAllProducts] BIT      NOT NULL,
    CONSTRAINT [PK_CouponPlan] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CouponPlan_Coupon] FOREIGN KEY ([CouponId]) REFERENCES [dbo].[Coupon] ([Id]),
    CONSTRAINT [FK_CouponPlan_Plan] FOREIGN KEY ([PlanId]) REFERENCES [dbo].[Plan] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_CouponPlan_PlanId]
    ON [dbo].[CouponPlan]([PlanId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_CouponPlan_CouponId]
    ON [dbo].[CouponPlan]([CouponId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

