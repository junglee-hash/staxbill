CREATE TABLE [dbo].[PaymentNote] (
    [Id]                       BIGINT   IDENTITY (1, 1) NOT NULL,
    [CreatedTimestamp]         DATETIME NOT NULL,
    [Amount]                   MONEY    NOT NULL,
    [InvoiceId]                BIGINT   NOT NULL,
    [PaymentId]                BIGINT   NOT NULL,
    [EffectiveTimestamp]       DATETIME NOT NULL,
    [SyncedToQuickBooks]       BIT      CONSTRAINT [df_SyncedToQuickBooks] DEFAULT ((0)) NOT NULL,
    [QuickBooksAttemptNumber]  INT      CONSTRAINT [df_PaymentNoteQuickBooksAttemptNumber] DEFAULT ((0)) NOT NULL,
    [SageIntacctId]            BIGINT   NULL,
    [SageIntacctAttemptNumber] INT      CONSTRAINT [DF_PaymentNoteSageIntacctAttemptNumber] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_PaymentNote] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_PaymentNote_Invoice] FOREIGN KEY ([InvoiceId]) REFERENCES [dbo].[Invoice] ([Id]),
    CONSTRAINT [FK_PaymentNote_Payment] FOREIGN KEY ([PaymentId]) REFERENCES [dbo].[Payment] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_PaymentNote_InvoiceId]
    ON [dbo].[PaymentNote]([InvoiceId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_PaymentNote_PaymentId]
    ON [dbo].[PaymentNote]([PaymentId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

