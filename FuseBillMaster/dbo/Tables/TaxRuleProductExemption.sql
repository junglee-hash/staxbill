CREATE TABLE [dbo].[TaxRuleProductExemption] (
    [Id]        BIGINT IDENTITY (1, 1) NOT NULL,
    [TaxRuleId] BIGINT NOT NULL,
    [ProductId] BIGINT NOT NULL,
    CONSTRAINT [PK_TaxRuleProductExemption] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_TaxRuleProductExemption_Product] FOREIGN KEY ([ProductId]) REFERENCES [dbo].[Product] ([Id]),
    CONSTRAINT [FK_TaxRuleProductExemption_TaxRule] FOREIGN KEY ([TaxRuleId]) REFERENCES [dbo].[TaxRule] ([Id])
);


GO

