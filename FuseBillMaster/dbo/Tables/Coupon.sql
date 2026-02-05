CREATE TABLE [dbo].[Coupon] (
    [Id]                BIGINT         IDENTITY (1, 1) NOT NULL,
    [Name]              NVARCHAR (255) NOT NULL,
    [Description]       NVARCHAR (500) NULL,
    [StatusId]          INT            NOT NULL,
    [ApplyToAllPlans]   BIT            NOT NULL,
    [CreatedTimestamp]  DATETIME       NOT NULL,
    [ModifiedTimestamp] DATETIME       NOT NULL,
    [AccountId]         BIGINT         NOT NULL,
    [OneTimeUse]        BIT            CONSTRAINT [DF_OneTimeUse] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Coupon] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_Coupon_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id]),
    CONSTRAINT [FK_Coupon_CouponStatus] FOREIGN KEY ([StatusId]) REFERENCES [Lookup].[CouponStatus] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_Coupon_StatusId]
    ON [dbo].[Coupon]([StatusId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_Coupon_AccountId]
    ON [dbo].[Coupon]([AccountId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

