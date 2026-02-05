CREATE TABLE [dbo].[Price] (
    [Id]                  BIGINT          IDENTITY (1, 1) NOT NULL,
    [QuantityRangeId]     BIGINT          NOT NULL,
    [Amount]              DECIMAL (18, 6) NULL,
    [CurrencyId]          BIGINT          NOT NULL,
    [SalesforceId]        VARCHAR (100)   NULL,
    [ConditionAmount]     DECIMAL (18, 6) NULL,
    [VariableAmount]      DECIMAL (18, 6) NULL,
    [ConditionAmountDays] INT             CONSTRAINT [DF_ConditionAmountDays] DEFAULT (NULL) NULL,
    CONSTRAINT [PK_Price] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_Price_Currency] FOREIGN KEY ([CurrencyId]) REFERENCES [Lookup].[Currency] ([Id]),
    CONSTRAINT [FK_Price_PriceRange] FOREIGN KEY ([QuantityRangeId]) REFERENCES [dbo].[QuantityRange] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_Price_CurrencyId]
    ON [dbo].[Price]([CurrencyId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_Price_QuantityRangeId]
    ON [dbo].[Price]([QuantityRangeId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

