CREATE TABLE [dbo].[AccountMerchantCardRate] (
    [Id]                BIGINT         IDENTITY (1, 1) NOT NULL,
    [AccountId]         BIGINT         NOT NULL,
    [ShortCode]         VARCHAR (10)   NOT NULL,
    [Rate]              DECIMAL (5, 3) NOT NULL,
    [FlatRate]          DECIMAL (5, 3) NOT NULL,
    [CreatedTimestamp]  DATETIME       NOT NULL,
    [ModifiedTimestamp] DATETIME       NOT NULL,
    CONSTRAINT [PK_AccountMerchantCardRate] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_AccountMerchantCardRate_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_AccountMerchantCardRate_AccountId]
    ON [dbo].[AccountMerchantCardRate]([AccountId] ASC) WITH (FILLFACTOR = 100);


GO

