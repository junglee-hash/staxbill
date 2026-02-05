CREATE TABLE [dbo].[DraftTax] (
    [Id]             BIGINT IDENTITY (1, 1) NOT NULL,
    [TaxRuleId]      BIGINT NOT NULL,
    [DraftInvoiceId] BIGINT NOT NULL,
    [DraftChargeId]  BIGINT NOT NULL,
    [Amount]         MONEY  NOT NULL,
    [CurrencyId]     BIGINT NOT NULL,
    CONSTRAINT [pk_DraftTax] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_DraftTax_DraftCharge] FOREIGN KEY ([DraftChargeId]) REFERENCES [dbo].[DraftCharge] ([Id]),
    CONSTRAINT [FK_DraftTax_DraftInvoice] FOREIGN KEY ([DraftInvoiceId]) REFERENCES [dbo].[DraftInvoice] ([Id]),
    CONSTRAINT [fk_DraftTax_TaxRuleId] FOREIGN KEY ([TaxRuleId]) REFERENCES [dbo].[TaxRule] ([Id]) ON DELETE CASCADE
);


GO

CREATE NONCLUSTERED INDEX [IX_DraftTax_DraftChargeId]
    ON [dbo].[DraftTax]([DraftChargeId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_DraftTax_DraftInvoiceId]
    ON [dbo].[DraftTax]([DraftInvoiceId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

