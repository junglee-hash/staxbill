CREATE TABLE [dbo].[CreditAllocation] (
    [Id]                       BIGINT          IDENTITY (1, 1) NOT NULL,
    [CreditId]                 BIGINT          NOT NULL,
    [Amount]                   DECIMAL (18, 6) NOT NULL,
    [InvoiceId]                BIGINT          NOT NULL,
    [EffectiveTimestamp]       DATETIME        NOT NULL,
    [SyncedToQuickBooks]       BIT             CONSTRAINT [df_CreditAllocationSyncedToQuickBooks] DEFAULT ((0)) NOT NULL,
    [QuickBooksId]             BIGINT          NULL,
    [QuickBooksAttemptNumber]  INT             CONSTRAINT [df_CreditAllocationQuickBooksAttemptNumber] DEFAULT ((0)) NOT NULL,
    [SageIntacctId]            BIGINT          NULL,
    [SageIntacctAttemptNumber] INT             CONSTRAINT [DF_CreditAllocationSageIntacctAttemptNumber] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_CreditAllocation] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CreditAllocation_Credit] FOREIGN KEY ([CreditId]) REFERENCES [dbo].[Credit] ([Id]),
    CONSTRAINT [FK_CreditAllocation_Invoice] FOREIGN KEY ([InvoiceId]) REFERENCES [dbo].[Invoice] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_CreditAllocation_CreditId]
    ON [dbo].[CreditAllocation]([CreditId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_CreditAllocation_InvoiceId]
    ON [dbo].[CreditAllocation]([InvoiceId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

