CREATE TABLE [dbo].[InvoiceSignature] (
    [Id]                 BIGINT         IDENTITY (1, 1) NOT NULL,
    [AccountId]          BIGINT         NOT NULL,
    [Signature]          NVARCHAR (MAX) NOT NULL,
    [CreatedTimestamp]   DATETIME       NOT NULL,
    [EffectiveTimestamp] DATETIME       NOT NULL,
    [ModifiedTimestamp]  DATETIME       NOT NULL,
    CONSTRAINT [PK_InvoiceSignature] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_InvoiceSignature_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id])
);


GO

