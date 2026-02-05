CREATE TABLE [dbo].[Refund] (
    [Id]                       BIGINT         NOT NULL,
    [Reference]                NVARCHAR (500) NULL,
    [OriginalPaymentId]        BIGINT         NOT NULL,
    [PaymentActivityJournalId] BIGINT         NOT NULL,
    [QuickBooksId]             BIGINT         NULL,
    [QuickBooksAttemptNumber]  INT            CONSTRAINT [df_QuickBooksAttemptNumber] DEFAULT ((0)) NOT NULL,
    [NetsuiteId]               NVARCHAR (255) NULL,
    [ReferenceDate]            DATETIME       NULL,
    [IsQuickBooksRequeue]      BIT            NULL,
    [IsQuickBooksBlock]        BIT            NULL,
    [SyncedToSageIntacct]      BIT            CONSTRAINT [DF_RefundSyncedToSageIntacct] DEFAULT ((0)) NOT NULL,
    [SageIntacctId]            BIGINT         NULL,
    [SageIntacctAttemptNumber] INT            CONSTRAINT [DF_RefundSageIntacctAttemptNumber] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Refund] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_Refund_OriginalPayment] FOREIGN KEY ([OriginalPaymentId]) REFERENCES [dbo].[Payment] ([Id]),
    CONSTRAINT [FK_Refund_PaymentActivityJournal] FOREIGN KEY ([PaymentActivityJournalId]) REFERENCES [dbo].[PaymentActivityJournal] ([Id]),
    CONSTRAINT [FK_Refund_Transaction] FOREIGN KEY ([Id]) REFERENCES [dbo].[Transaction] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_Refund_OriginalPaymentId]
    ON [dbo].[Refund]([OriginalPaymentId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_Refund_PaymentActivityJournalId]
    ON [dbo].[Refund]([PaymentActivityJournalId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

