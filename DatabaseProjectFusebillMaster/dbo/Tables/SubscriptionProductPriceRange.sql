CREATE TABLE [dbo].[SubscriptionProductPriceRange] (
    [Id]                    BIGINT          IDENTITY (1, 1) NOT NULL,
    [SubscriptionProductId] BIGINT          NOT NULL,
    [Min]                   DECIMAL (18, 6) NOT NULL,
    [Max]                   DECIMAL (18, 6) NULL,
    [Amount]                DECIMAL (18, 6) NOT NULL,
    [ModifiedTimestamp]     DATETIME        NOT NULL,
    [ConditionAmount]       DECIMAL (18, 6) NULL,
    [VariableAmount]        DECIMAL (18, 6) NULL,
    [ConditionAmountDays]   INT             CONSTRAINT [DF_ConditionAmountDaysSubProduct] DEFAULT (NULL) NULL,
    CONSTRAINT [PK_SubscriptionProductPriceRange] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_SubscriptionProductPriceRange_SubscriptionProduct] FOREIGN KEY ([SubscriptionProductId]) REFERENCES [dbo].[SubscriptionProduct] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_SubscriptionProductPriceRange_SubscriptionProductId]
    ON [dbo].[SubscriptionProductPriceRange]([SubscriptionProductId] ASC)
    INCLUDE([Id], [Min], [Max], [Amount]) WITH (FILLFACTOR = 100);


GO

