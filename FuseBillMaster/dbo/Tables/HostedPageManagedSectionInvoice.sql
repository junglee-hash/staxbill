CREATE TABLE [dbo].[HostedPageManagedSectionInvoice] (
    [Id]                         BIGINT NOT NULL,
    [ShowLineItemDetails]        BIT    NOT NULL,
    [AllowPaymentInvoiceDetails] BIT    CONSTRAINT [DF_AllowPaymentInvoiceDetails] DEFAULT ((1)) NOT NULL,
    [AllowPaymentOverride]       BIT    CONSTRAINT [DF_AllowPaymentOverride] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_HostedPageManagedSectionInvoice] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_HostedPageManagedSectionInvoice_HostedPageManagedSelfServicePortal] FOREIGN KEY ([Id]) REFERENCES [dbo].[HostedPageManagedSelfServicePortal] ([Id])
);


GO

