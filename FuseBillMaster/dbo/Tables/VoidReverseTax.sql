CREATE TABLE [dbo].[VoidReverseTax] (
    [Id]                   BIGINT NOT NULL,
    [OriginalReverseTaxId] BIGINT NOT NULL,
    [CreditNoteId]         BIGINT NOT NULL,
    CONSTRAINT [pk_VoidReverseTax] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [fk_VoidReverseTax_CreditNoteId] FOREIGN KEY ([CreditNoteId]) REFERENCES [dbo].[CreditNote] ([Id]),
    CONSTRAINT [fk_VoidReverseTax_OriginalReverseTaxId] FOREIGN KEY ([OriginalReverseTaxId]) REFERENCES [dbo].[ReverseTax] ([Id]),
    CONSTRAINT [fk_VoidReverseTaxId] FOREIGN KEY ([Id]) REFERENCES [dbo].[Transaction] ([Id])
);


GO

