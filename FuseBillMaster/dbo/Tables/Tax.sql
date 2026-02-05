CREATE TABLE [dbo].[Tax] (
    [Id]                      BIGINT          NOT NULL,
    [InvoiceId]               BIGINT          NOT NULL,
    [TaxRuleId]               BIGINT          NOT NULL,
    [ChargeId]                BIGINT          NOT NULL,
    [RemainingReversalAmount] DECIMAL (18, 6) NOT NULL,
    CONSTRAINT [pk_Tax] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_Tax_Charge] FOREIGN KEY ([ChargeId]) REFERENCES [dbo].[Charge] ([Id]),
    CONSTRAINT [fk_Tax_Id] FOREIGN KEY ([Id]) REFERENCES [dbo].[Transaction] ([Id]),
    CONSTRAINT [FK_Tax_Invoice] FOREIGN KEY ([InvoiceId]) REFERENCES [dbo].[Invoice] ([Id]),
    CONSTRAINT [fk_Tax_TaxRuleId] FOREIGN KEY ([TaxRuleId]) REFERENCES [dbo].[TaxRule] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_Tax_ChargeId]
    ON [dbo].[Tax]([ChargeId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_Tax_InvoiceId]
    ON [dbo].[Tax]([InvoiceId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_Tax_TaxRuleId]
    ON [dbo].[Tax]([TaxRuleId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

