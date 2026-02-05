CREATE TABLE [dbo].[CustomerEmailLogInvoice] (
    [Id]                 BIGINT IDENTITY (1, 1) NOT NULL,
    [CustomerEmailLogId] BIGINT NOT NULL,
    [InvoiceId]          BIGINT NOT NULL,
    CONSTRAINT [PK_CustomerEmailLogInvoice] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CustomerEmailLogInvoice_CustomerEmailLog] FOREIGN KEY ([CustomerEmailLogId]) REFERENCES [dbo].[CustomerEmailLog] ([Id]),
    CONSTRAINT [FK_CustomerEmailLogInvoice_Invoice] FOREIGN KEY ([InvoiceId]) REFERENCES [dbo].[Invoice] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_CustomerEmailLogInvoice_CustomerEmailLogId]
    ON [dbo].[CustomerEmailLogInvoice]([CustomerEmailLogId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_CustomerEmailLogInvoice_InvoiceId]
    ON [dbo].[CustomerEmailLogInvoice]([InvoiceId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

