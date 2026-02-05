CREATE TABLE [dbo].[CouponPlanProduct] (
    [Id]                BIGINT   IDENTITY (1, 1) NOT NULL,
    [CouponPlanId]      BIGINT   NOT NULL,
    [PlanProductKey]    BIGINT   NOT NULL,
    [CreatedTimestamp]  DATETIME NOT NULL,
    [ModifiedTimestamp] DATETIME NOT NULL,
    CONSTRAINT [PK_CouponPlanProduct] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CouponPlanProduct_CouponPlan] FOREIGN KEY ([CouponPlanId]) REFERENCES [dbo].[CouponPlan] ([Id]),
    CONSTRAINT [FK_CouponPlanProduct_PlanProductKey] FOREIGN KEY ([PlanProductKey]) REFERENCES [dbo].[PlanProductKey] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_CouponPlanProduct_CouponPlanId]
    ON [dbo].[CouponPlanProduct]([CouponPlanId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_CouponPlanProduct_PlanProductKey]
    ON [dbo].[CouponPlanProduct]([PlanProductKey] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

