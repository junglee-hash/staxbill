CREATE TABLE [dbo].[Transaction] (
    [Id]                 BIGINT          IDENTITY (1, 1) NOT NULL,
    [CreatedTimestamp]   DATETIME        NOT NULL,
    [CustomerId]         BIGINT          NOT NULL,
    [Amount]             MONEY           NOT NULL,
    [EffectiveTimestamp] DATETIME        NOT NULL,
    [TransactionTypeId]  INT             NOT NULL,
    [Description]        NVARCHAR (2000) NULL,
    [CurrencyId]         BIGINT          NOT NULL,
    [SortOrder]          INT             NOT NULL,
    [AccountId]          BIGINT          NULL,
    [ModifiedTimestamp]  DATETIME        NULL,
    CONSTRAINT [PK_Transaction] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_Transaction_Customer] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([Id]),
    CONSTRAINT [FK_Transaction_TransactionType] FOREIGN KEY ([TransactionTypeId]) REFERENCES [Lookup].[TransactionType] ([Id]),
    CONSTRAINT [FK_TransactionCurrencyId_Currency] FOREIGN KEY ([CurrencyId]) REFERENCES [Lookup].[Currency] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FIX_Transaction_AccountId_TransactionTypeId_CurrencyId_EffectiveTimestamp_INCL]
    ON [dbo].[Transaction]([AccountId] ASC, [TransactionTypeId] ASC, [CurrencyId] ASC, [EffectiveTimestamp] ASC)
    INCLUDE([CustomerId], [Amount]) WHERE ([Amount]<>(0)) WITH (FILLFACTOR = 100);


GO

CREATE NONCLUSTERED INDEX [IX_Transaction_EffectiveTimestamp_TransactionTypeId]
    ON [dbo].[Transaction]([EffectiveTimestamp] ASC, [TransactionTypeId] ASC)
    INCLUDE([Id], [CustomerId], [Amount]) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_Transaction_CustomerId_AccountId]
    ON [dbo].[Transaction]([CustomerId] ASC, [AccountId] ASC) WITH (FILLFACTOR = 100);


GO

CREATE NONCLUSTERED INDEX [IX_Transaction_ModifiedTimestamp_TransactionTypeId]
    ON [dbo].[Transaction]([ModifiedTimestamp] ASC, [TransactionTypeId] ASC) WITH (FILLFACTOR = 100);


GO

CREATE NONCLUSTERED INDEX [IX_Transaction_CustomerId_CurrencyId_EffectiveTimestamp_TransactionTypeId]
    ON [dbo].[Transaction]([CustomerId] ASC, [CurrencyId] ASC, [EffectiveTimestamp] ASC, [TransactionTypeId] ASC)
    INCLUDE([Amount]) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_Transaction_TransactionTypeId_CreatedTimestamp]
    ON [dbo].[Transaction]([TransactionTypeId] ASC, [CreatedTimestamp] ASC)
    INCLUDE([Id], [CustomerId], [Amount], [CurrencyId]) WITH (FILLFACTOR = 100);


GO

CREATE NONCLUSTERED INDEX [IX_Transaction_CustomerId_EffectiveTimestamp]
    ON [dbo].[Transaction]([CustomerId] ASC, [EffectiveTimestamp] ASC)
    INCLUDE([Id]) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

