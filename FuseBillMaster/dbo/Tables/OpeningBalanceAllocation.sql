CREATE TABLE [dbo].[OpeningBalanceAllocation] (
    [Id]                 BIGINT          IDENTITY (1, 1) NOT NULL,
    [OpeningBalanceId]   BIGINT          NOT NULL,
    [Amount]             DECIMAL (18, 6) NOT NULL,
    [InvoiceId]          BIGINT          NOT NULL,
    [EffectiveTimestamp] DATETIME        NOT NULL,
    CONSTRAINT [PK_OpeningBalanceAllocation] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_OpeningBalanceAllocation_Invoice] FOREIGN KEY ([InvoiceId]) REFERENCES [dbo].[Invoice] ([Id]),
    CONSTRAINT [FK_OpeningBalanceAllocation_OpeningBalance] FOREIGN KEY ([OpeningBalanceId]) REFERENCES [dbo].[OpeningBalance] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_OpeningBalanceAllocation_InvoiceId]
    ON [dbo].[OpeningBalanceAllocation]([InvoiceId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_OpeningBalanceAllocation_OpeningBalanceId]
    ON [dbo].[OpeningBalanceAllocation]([OpeningBalanceId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

