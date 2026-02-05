CREATE TABLE [dbo].[AccountHubspotCouponCodeMapping] (
    [Id]                            BIGINT   IDENTITY (1, 1) NOT NULL,
    [AccountHubSpotConfigurationId] BIGINT   NOT NULL,
    [CouponCodeId]                  BIGINT   NOT NULL,
    [CreatedTimestamp]              DATETIME NOT NULL,
    [ModifiedTimestamp]             DATETIME NOT NULL,
    CONSTRAINT [PK_AccountHubspotCouponCodeMapping] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_AccountHubspotCouponCodeMapping_AccountHubSpotConfiguration] FOREIGN KEY ([AccountHubSpotConfigurationId]) REFERENCES [dbo].[AccountHubSpotConfiguration] ([Id]),
    CONSTRAINT [FK_AccountHubspotCouponCodeMapping_CouponCode] FOREIGN KEY ([CouponCodeId]) REFERENCES [dbo].[CouponCode] ([Id])
);


GO

