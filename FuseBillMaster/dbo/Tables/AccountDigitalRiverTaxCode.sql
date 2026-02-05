CREATE TABLE [dbo].[AccountDigitalRiverTaxCode] (
    [Id]               BIGINT   IDENTITY (1, 1) NOT NULL,
    [AccountId]        BIGINT   NOT NULL,
    [TaxCodeId]        BIGINT   NOT NULL,
    [CreatedTimestamp] DATETIME NOT NULL,
    [SortOrder]        INT      NOT NULL,
    CONSTRAINT [PK_AccountDigitalRiverTaxCode] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_AccountDigitalRiverTaxCode_AccountId] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id]),
    CONSTRAINT [FK_AccountDigitalRiverTaxCode_TaxCodeId] FOREIGN KEY ([TaxCodeId]) REFERENCES [dbo].[DigitalRiverTaxCode] ([Id])
);


GO

