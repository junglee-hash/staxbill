CREATE TABLE [dbo].[DebitAllocation] (
    [Id]                 BIGINT          IDENTITY (1, 1) NOT NULL,
    [DebitId]            BIGINT          NOT NULL,
    [Amount]             DECIMAL (18, 6) NOT NULL,
    [InvoiceId]          BIGINT          NOT NULL,
    [EffectiveTimestamp] DATETIME        NOT NULL,
    CONSTRAINT [PK_DebitAllocation] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_DebitAllocation_Debit] FOREIGN KEY ([DebitId]) REFERENCES [dbo].[Debit] ([Id]),
    CONSTRAINT [FK_DebitAllocation_Invoice] FOREIGN KEY ([InvoiceId]) REFERENCES [dbo].[Invoice] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_DebitAllocation_InvoiceId]
    ON [dbo].[DebitAllocation]([InvoiceId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_DebitAllocation_DebitId]
    ON [dbo].[DebitAllocation]([DebitId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

