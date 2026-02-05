CREATE TABLE [dbo].[CouponCode] (
    [Id]                BIGINT        IDENTITY (1, 1) NOT NULL,
    [CouponId]          BIGINT        NOT NULL,
    [Code]              VARCHAR (255) NOT NULL,
    [CreatedTimestamp]  DATETIME      NOT NULL,
    [ModifiedTimestamp] DATETIME      NOT NULL,
    [AccountId]         BIGINT        NOT NULL,
    [TimesUsed]         INT           CONSTRAINT [DF_CouponCode_TimesUsed] DEFAULT ((0)) NOT NULL,
    [RemainingUsages]   INT           NULL,
    CONSTRAINT [PK_CouponCode] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CouponCode_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id]),
    CONSTRAINT [FK_CouponCode_Coupon] FOREIGN KEY ([CouponId]) REFERENCES [dbo].[Coupon] ([Id]),
    CONSTRAINT [IX_CouponCode] UNIQUE NONCLUSTERED ([AccountId] ASC, [Code] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON)
);


GO

CREATE NONCLUSTERED INDEX [FKIX_CouponCode_CouponId]
    ON [dbo].[CouponCode]([CouponId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

