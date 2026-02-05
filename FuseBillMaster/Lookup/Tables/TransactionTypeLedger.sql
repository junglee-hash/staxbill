CREATE TABLE [Lookup].[TransactionTypeLedger] (
    [TransactionTypeId] INT           NOT NULL,
    [EntryType]         VARCHAR (6)   NOT NULL,
    [LedgerTypeId]      BIGINT        NOT NULL,
    [PivotColumnName]   VARCHAR (100) NOT NULL,
    CONSTRAINT [PK_TransactionTypeLedger] PRIMARY KEY CLUSTERED ([TransactionTypeId] ASC, [EntryType] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [CHK_TransactionTypeLedger_EntryType] CHECK ([EntryType]='Credit' OR [EntryType]='Debit'),
    CONSTRAINT [FK_TransactionTypeLedger_LedgerTypeId] FOREIGN KEY ([LedgerTypeId]) REFERENCES [Lookup].[LedgerType] ([Id]),
    CONSTRAINT [FK_TransactionTypeLedger_TransactionTypeId] FOREIGN KEY ([TransactionTypeId]) REFERENCES [Lookup].[TransactionType] ([Id])
);


GO

