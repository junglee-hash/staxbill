CREATE TABLE [dbo].[InvoiceJournal] (
    [Id]                 BIGINT   IDENTITY (1, 1) NOT NULL,
    [InvoiceId]          BIGINT   NOT NULL,
    [SumOfCharges]       MONEY    NOT NULL,
    [SumOfPayments]      MONEY    NOT NULL,
    [SumOfRefunds]       MONEY    NOT NULL,
    [SumOfCreditNotes]   MONEY    NOT NULL,
    [SumOfWriteOffs]     MONEY    NOT NULL,
    [OutstandingBalance] MONEY    NOT NULL,
    [CreatedTimestamp]   DATETIME NOT NULL,
    [SumOfTaxes]         MONEY    NOT NULL,
    [SumOfDiscounts]     MONEY    NOT NULL,
    [IsActive]           BIT      NOT NULL,
    CONSTRAINT [PK_InvoiceJournal] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_InvoiceJournal_Invoice] FOREIGN KEY ([InvoiceId]) REFERENCES [dbo].[Invoice] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_InvoiceJournal_InvoiceId]
    ON [dbo].[InvoiceJournal]([InvoiceId] ASC, [CreatedTimestamp] ASC)
    INCLUDE([Id], [SumOfCharges], [SumOfPayments], [SumOfRefunds], [SumOfCreditNotes], [SumOfWriteOffs], [OutstandingBalance], [SumOfTaxes], [SumOfDiscounts], [IsActive]) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE UNIQUE NONCLUSTERED INDEX [UQ_InvoiceJournal_InvoiceId_IsActive, InvoiceId, IsActive]
    ON [dbo].[InvoiceJournal]([InvoiceId] ASC, [IsActive] ASC) WHERE ([IsActive]=(1)) WITH (FILLFACTOR = 80);


GO

