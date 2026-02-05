CREATE TABLE [dbo].[SubscriptionCouponCode] (
    [Id]               BIGINT   IDENTITY (1, 1) NOT NULL,
    [SubscriptionId]   BIGINT   NOT NULL,
    [CouponCodeId]     BIGINT   NOT NULL,
    [CreatedTimestamp] DATETIME NOT NULL,
    [StatusId]         INT      NOT NULL,
    [DeletedTimestamp] DATETIME NULL,
    CONSTRAINT [PK_SubscriptionCouponCode] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_SubscriptionCouponCode_CouponCode] FOREIGN KEY ([CouponCodeId]) REFERENCES [dbo].[CouponCode] ([Id]),
    CONSTRAINT [FK_SubscriptionCouponCode_Subscription] FOREIGN KEY ([SubscriptionId]) REFERENCES [dbo].[Subscription] ([Id]) ON DELETE CASCADE,
    CONSTRAINT [FK_SubscriptionCouponCode_SubscriptionCouponCodeStatus] FOREIGN KEY ([StatusId]) REFERENCES [Lookup].[SubscriptionCouponCodeStatus] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_SubscriptionCouponCode_CouponCodeId]
    ON [dbo].[SubscriptionCouponCode]([CouponCodeId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_SubscriptionCouponCode_SubscriptionId]
    ON [dbo].[SubscriptionCouponCode]([SubscriptionId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_SubscriptionCouponCode_StatusId]
    ON [dbo].[SubscriptionCouponCode]([StatusId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

