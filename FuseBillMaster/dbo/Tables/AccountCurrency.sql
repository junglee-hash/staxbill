CREATE TABLE [dbo].[AccountCurrency] (
    [Id]               BIGINT IDENTITY (1, 1) NOT NULL,
    [AccountId]        BIGINT NOT NULL,
    [CurrencyId]       BIGINT NOT NULL,
    [IsDefault]        BIT    NOT NULL,
    [CurrencyStatusId] INT    NOT NULL,
    CONSTRAINT [PK_AccountCurrency] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_AccountCurrency_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id]),
    CONSTRAINT [FK_AccountCurrency_Currency] FOREIGN KEY ([CurrencyId]) REFERENCES [Lookup].[Currency] ([Id]),
    CONSTRAINT [FK_AccountCurrency_CurrencyStatus] FOREIGN KEY ([CurrencyStatusId]) REFERENCES [Lookup].[CurrencyStatus] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_AccountCurrency_AccountId]
    ON [dbo].[AccountCurrency]([AccountId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_AccountCurrency_CurrencyStatusId]
    ON [dbo].[AccountCurrency]([CurrencyStatusId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_AccountCurrency_AccountId_CurrencyId]
    ON [dbo].[AccountCurrency]([AccountId] ASC, [CurrencyId] ASC)
    INCLUDE([IsDefault]) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_AccountCurrency_CurrencyId]
    ON [dbo].[AccountCurrency]([CurrencyId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

