CREATE TABLE [dbo].[CreditNote] (
    [Id]                BIGINT          IDENTITY (1, 1) NOT NULL,
    [InvoiceId]         BIGINT          NOT NULL,
    [Amount]            DECIMAL (18, 6) NOT NULL,
    [CreditNoteGroupId] BIGINT          NOT NULL,
    CONSTRAINT [PK_CreditNote] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CreditNote_CreditNoteGroup] FOREIGN KEY ([CreditNoteGroupId]) REFERENCES [dbo].[CreditNoteGroup] ([Id]),
    CONSTRAINT [FK_CreditNote_Invoice] FOREIGN KEY ([InvoiceId]) REFERENCES [dbo].[Invoice] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_CreditNote_InvoiceId]
    ON [dbo].[CreditNote]([InvoiceId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

