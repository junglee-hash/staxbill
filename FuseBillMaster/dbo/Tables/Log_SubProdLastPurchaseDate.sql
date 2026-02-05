CREATE TABLE [dbo].[Log_SubProdLastPurchaseDate] (
    [SubscriptionProductId] BIGINT   NOT NULL,
    [CreatedTimestamp]      DATETIME NULL,
    CONSTRAINT [PK_Log_SubProdLastPurchaseDate] PRIMARY KEY CLUSTERED ([SubscriptionProductId] ASC)
);


GO

