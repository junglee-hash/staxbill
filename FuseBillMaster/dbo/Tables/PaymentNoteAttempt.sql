CREATE TABLE [dbo].[PaymentNoteAttempt] (
    [Id]                       BIGINT   IDENTITY (1, 1) NOT NULL,
    [CreatedTimestamp]         DATETIME NOT NULL,
    [Amount]                   MONEY    NOT NULL,
    [InvoiceId]                BIGINT   NOT NULL,
    [PaymentActivityJournalId] BIGINT   NOT NULL,
    [EffectiveTimestamp]       DATETIME NOT NULL,
    CONSTRAINT [PK_PaymentNoteAttempt] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_PaymentNote_PaymentActivityJournal] FOREIGN KEY ([PaymentActivityJournalId]) REFERENCES [dbo].[PaymentActivityJournal] ([Id]),
    CONSTRAINT [FK_PaymentNoteAttempt_Invoice] FOREIGN KEY ([InvoiceId]) REFERENCES [dbo].[Invoice] ([Id])
);


GO

