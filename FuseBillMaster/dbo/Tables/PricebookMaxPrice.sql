CREATE TABLE [dbo].[PricebookMaxPrice] (
    [Id]                BIGINT          IDENTITY (1, 1) NOT NULL,
    [PricebookId]       BIGINT          NOT NULL,
    [CreatedTimestamp]  DATETIME        NOT NULL,
    [ModifiedTimestamp] DATETIME        NOT NULL,
    [Amount]            DECIMAL (18, 6) NOT NULL,
    [CurrencyId]        BIGINT          NOT NULL,
    CONSTRAINT [PK_PricebookMaxPrice] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_PricebookMaxPrice_Currency] FOREIGN KEY ([CurrencyId]) REFERENCES [Lookup].[Currency] ([Id]),
    CONSTRAINT [FK_PricebookMaxPrice_Pricebook] FOREIGN KEY ([PricebookId]) REFERENCES [dbo].[Pricebook] ([Id])
);


GO

