CREATE TABLE [dbo].[InvoiceChildTaxDocument] (
    [Id]         BIGINT           IDENTITY (1, 1) NOT NULL,
    [InvoiceId]  BIGINT           NOT NULL,
    [DocCode]    UNIQUEIDENTIFIER NOT NULL,
    [CustomerId] BIGINT           NOT NULL,
    [Committed]  BIT              NOT NULL,
    CONSTRAINT [PK_InvoiceChildTaxDocument] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_InvoiceChildTaxDocument_Customer] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([Id]),
    CONSTRAINT [FK_InvoiceChildTaxDocument_Invoice] FOREIGN KEY ([InvoiceId]) REFERENCES [dbo].[Invoice] ([Id])
);


GO

