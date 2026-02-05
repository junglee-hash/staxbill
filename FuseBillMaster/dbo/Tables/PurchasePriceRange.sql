CREATE TABLE [dbo].[PurchasePriceRange] (
    [Id]                  BIGINT          IDENTITY (1, 1) NOT NULL,
    [PurchaseId]          BIGINT          NOT NULL,
    [Min]                 DECIMAL (18, 6) NOT NULL,
    [Max]                 DECIMAL (18, 6) NULL,
    [Amount]              DECIMAL (18, 6) NOT NULL,
    [ConditionAmount]     DECIMAL (18, 6) NULL,
    [VariableAmount]      DECIMAL (18, 6) NULL,
    [ConditionAmountDays] INT             CONSTRAINT [DF_ConditionAmountDaysPurchase] DEFAULT (NULL) NULL,
    CONSTRAINT [PK_PurchasePriceRange] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_PurchasePriceRange_Purchase] FOREIGN KEY ([PurchaseId]) REFERENCES [dbo].[Purchase] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_PurchasePriceRange_PurchaseId]
    ON [dbo].[PurchasePriceRange]([PurchaseId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

