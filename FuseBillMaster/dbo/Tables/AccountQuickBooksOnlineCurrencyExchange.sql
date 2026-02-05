CREATE TABLE [dbo].[AccountQuickBooksOnlineCurrencyExchange] (
    [Id]                 BIGINT          IDENTITY (1, 1) NOT NULL,
    [AccountId]          BIGINT          NOT NULL,
    [CurrencyId]         BIGINT          NOT NULL,
    [ExchangeRate]       DECIMAL (19, 6) CONSTRAINT [DF_AccountQuickBooksOnlineCurrencyExchange_ExchangeRate] DEFAULT ((1)) NOT NULL,
    [CreatedTimestamp]   DATETIME        NOT NULL,
    [EffectiveTimestamp] DATETIME        NOT NULL,
    CONSTRAINT [PK_AccountQuickBooksOnlineCurrencyExchange] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_AccountQuickBooksOnlineCurrencyExchange_AccountId] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id]) ON DELETE CASCADE,
    CONSTRAINT [FK_AccountQuickBooksOnlineCurrencyExchange_CurrencyId] FOREIGN KEY ([CurrencyId]) REFERENCES [Lookup].[Currency] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_AccountQuickBooksOnlineCurrencyExchange_AccountId_EffectiveTimestamp]
    ON [dbo].[AccountQuickBooksOnlineCurrencyExchange]([AccountId] ASC, [EffectiveTimestamp] ASC) WITH (FILLFACTOR = 100);


GO

