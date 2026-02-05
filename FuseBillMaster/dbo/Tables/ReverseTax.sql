CREATE TABLE [dbo].[ReverseTax] (
    [Id]              BIGINT NOT NULL,
    [OriginalTaxId]   BIGINT NOT NULL,
    [CreditNoteId]    BIGINT NOT NULL,
    [ReverseChargeId] BIGINT NOT NULL,
    CONSTRAINT [pk_ReverseTax] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [fk_ReverseTax_CreditNoteId] FOREIGN KEY ([CreditNoteId]) REFERENCES [dbo].[CreditNote] ([Id]),
    CONSTRAINT [fk_ReverseTax_Id] FOREIGN KEY ([Id]) REFERENCES [dbo].[Transaction] ([Id]),
    CONSTRAINT [fk_ReverseTax_OriginalTaxId] FOREIGN KEY ([OriginalTaxId]) REFERENCES [dbo].[Tax] ([Id]),
    CONSTRAINT [fk_ReverseTax_ReverseChargeId] FOREIGN KEY ([ReverseChargeId]) REFERENCES [dbo].[ReverseCharge] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_ReverseTax_OriginalTaxId]
    ON [dbo].[ReverseTax]([OriginalTaxId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_ReverseTax_ReverseChargeId]
    ON [dbo].[ReverseTax]([ReverseChargeId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_ReverseTax_CreditNoteId]
    ON [dbo].[ReverseTax]([CreditNoteId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

