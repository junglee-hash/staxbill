CREATE TABLE [dbo].[CustomerEmailLogDraftInvoice] (
    [Id]                 BIGINT IDENTITY (1, 1) NOT NULL,
    [CustomerEmailLogId] BIGINT NOT NULL,
    [DraftInvoiceId]     BIGINT NOT NULL,
    CONSTRAINT [PK_CustomerEmailLogDraftInvoice] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_CustomerEmailLogDraftInvoice_CustomerEmailLog] FOREIGN KEY ([CustomerEmailLogId]) REFERENCES [dbo].[CustomerEmailLog] ([Id]),
    CONSTRAINT [FK_CustomerEmailLogDraftInvoice_DraftInvoice] FOREIGN KEY ([DraftInvoiceId]) REFERENCES [dbo].[DraftInvoice] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_CustomerEmailLogDraftInvoice_DraftInvoiceId]
    ON [dbo].[CustomerEmailLogDraftInvoice]([DraftInvoiceId] ASC) WITH (FILLFACTOR = 100);


GO

