CREATE TABLE [dbo].[CustomerInvoiceSetting] (
    [Id]                                        BIGINT   NOT NULL,
    [RollUpTaxes]                               BIT      NULL,
    [ShowTrackedItemName]                       BIT      NULL,
    [ShowTrackedItemReference]                  BIT      NULL,
    [ShowTrackedItemDescription]                BIT      NULL,
    [RollUpDiscounts]                           BIT      NULL,
    [TrackedItemDisplayFormatId]                INT      NULL,
    [ShowTrackedItemCreatedDate]                BIT      NULL,
    [ModifiedTimestamp]                         DATETIME NOT NULL,
    [InvoiceSummarization]                      BIT      CONSTRAINT [DF_PdfRollUpByPlanProduct] DEFAULT ((0)) NOT NULL,
    [PdfRollUpDisplayName]                      BIT      CONSTRAINT [DF_PdfRollUpDisplayName] DEFAULT ((1)) NOT NULL,
    [PdfRollUpDisplayDescription]               BIT      CONSTRAINT [DF_PdfRollUpDisplayDescription] DEFAULT ((1)) NOT NULL,
    [PdfRollUpDisplayAllUnitPrices]             BIT      CONSTRAINT [DF_PdfRollUpDisplayAllUnitPrices] DEFAULT ((1)) NOT NULL,
    [PdfInvoiceEmailAttachmentOption]           TINYINT  CONSTRAINT [DF_PdfInvoiceEmailAttachmentOption] DEFAULT ((1)) NOT NULL,
    [InvoiceSummarizationOption]                TINYINT  CONSTRAINT [DF_InvoiceSummarizationOption] DEFAULT ((1)) NULL,
    [InvoiceSummarizationFollowAccountDefaults] BIT      CONSTRAINT [DF_CustomerInvoiceSetting_InvoiceSummarizationFollowAccountDefaults] DEFAULT ((1)) NOT NULL,
    [DraftInvoiceIncludeWatermark]              BIT      NULL,
    [ProjectedInvoiceIncludeWatermark]          BIT      NULL,
    [InvoiceIncludeWatermark]                   BIT      NULL,
    CONSTRAINT [PK_CustomerInvoiceSetting] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CustomerInvoiceSetting_Customer] FOREIGN KEY ([Id]) REFERENCES [dbo].[Customer] ([Id]) ON DELETE CASCADE,
    CONSTRAINT [FK_CustomerInvoiceSetting_InvoiceSummarizationOption] FOREIGN KEY ([InvoiceSummarizationOption]) REFERENCES [Lookup].[InvoiceSummarizationOption] ([Id]),
    CONSTRAINT [FK_CustomerInvoiceSetting_TrackedItemDisplayFormat] FOREIGN KEY ([TrackedItemDisplayFormatId]) REFERENCES [Lookup].[TrackedItemDisplayFormat] ([Id]),
    CONSTRAINT [FK_PdfInvoiceEmailAttachmentOption_InvoiceEmailAttachmentOption] FOREIGN KEY ([PdfInvoiceEmailAttachmentOption]) REFERENCES [Lookup].[InvoiceEmailAttachmentOption] ([Id])
);


GO

