CREATE TABLE [dbo].[AccountInvoicePreference] (
    [Id]                                  BIGINT          NOT NULL,
    [NextInvoiceNumber]                   INT             CONSTRAINT [DF_AccountInvoicePreference_NextInvoiceNumber] DEFAULT ((1)) NOT NULL,
    [InvoiceSignature]                    NVARCHAR (MAX)  NULL,
    [ShowShippingAddress]                 BIT             NOT NULL,
    [InvoiceNote]                         NVARCHAR (4000) NULL,
    [RollUpTaxes]                         BIT             CONSTRAINT [DF_RollUpTaxes] DEFAULT ((1)) NOT NULL,
    [PurchaseLabel]                       NVARCHAR (255)  NOT NULL,
    [ShowTrackedItemName]                 BIT             DEFAULT ((0)) NOT NULL,
    [ShowTrackedItemReference]            BIT             DEFAULT ((0)) NOT NULL,
    [ShowTrackedItemDescription]          BIT             DEFAULT ((0)) NOT NULL,
    [InvoiceCustomerReferenceOption]      INT             DEFAULT ((2)) NOT NULL,
    [LayoutId]                            INT             DEFAULT ((1)) NOT NULL,
    [RollUpDiscounts]                     BIT             DEFAULT ((0)) NOT NULL,
    [ProjectedIncludeWatermark]           BIT             DEFAULT ((0)) NOT NULL,
    [ProjectedNotes]                      NVARCHAR (4000) NULL,
    [TrackedItemDisplayFormatId]          INT             NULL,
    [ShowTrackedItemCreatedDate]          BIT             CONSTRAINT [DF_ShowTrackedItemCreatedDate] DEFAULT ((0)) NOT NULL,
    [TrackedItemNameFieldOverride]        NVARCHAR (100)  NULL,
    [TrackedItemReferenceFieldOverride]   NVARCHAR (100)  NULL,
    [TrackedItemDescriptionFieldOverride] NVARCHAR (100)  NULL,
    [TrackedItemCreatedDateFieldOverride] NVARCHAR (100)  NULL,
    [TrackedItemPageLabelOverride]        NVARCHAR (100)  NULL,
    [TrackedItemMainInvoiceMessage]       NVARCHAR (500)  NULL,
    [DraftInvoiceIncludeWatermark]        BIT             NOT NULL,
    [ShowServiceDates]                    BIT             CONSTRAINT [DF_AccountInvoicePreference_ShowServiceDates] DEFAULT ((1)) NOT NULL,
    [InvoiceSummarization]                BIT             CONSTRAINT [DF_AccountInvoicePreference_InvoiceSummarization] DEFAULT ((0)) NOT NULL,
    [PdfRollUpDisplayName]                BIT             CONSTRAINT [DF_AccountInvoicePreference_PdfRollUpDisplayName] DEFAULT ((1)) NOT NULL,
    [PdfRollUpDisplayDescription]         BIT             CONSTRAINT [DF_AccountInvoicePreference_PdfRollUpDisplayDescription] DEFAULT ((1)) NOT NULL,
    [PdfRollUpDisplayAllUnitPrices]       BIT             CONSTRAINT [DF_AccountInvoicePreference_PdfRollUpDisplayAllUnitPrices] DEFAULT ((1)) NOT NULL,
    [PdfInvoiceEmailAttachmentOption]     TINYINT         CONSTRAINT [DF_AccountInvoicePreference_PdfInvoiceEmailAttachmentOption] DEFAULT ((1)) NOT NULL,
    [InvoiceSummarizationOption]          TINYINT         CONSTRAINT [DF_AccountInvoicePreference_InvoiceSummarizationOption] DEFAULT ((1)) NOT NULL,
    [ChargeGroupOrderId]                  TINYINT         CONSTRAINT [DF_ChargeGroupOrderId] DEFAULT ((1)) NOT NULL,
    [ShowPaymentDetails]                  BIT             CONSTRAINT [DF_ShowPaymentDetails] DEFAULT ((0)) NOT NULL,
    [InvoiceIncludeWatermark]             BIT             CONSTRAINT [DF_InvoiceIncludeWatermark] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_AccountInvoicePreference] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_AccountInvoicePreference_AccountPreference] FOREIGN KEY ([Id]) REFERENCES [dbo].[AccountPreference] ([Id]),
    CONSTRAINT [FK_AccountInvoicePreference_ChargeGroupOrder] FOREIGN KEY ([ChargeGroupOrderId]) REFERENCES [Lookup].[ChargeGroupOrder] ([Id]),
    CONSTRAINT [FK_AccountInvoicePreference_InvoiceCustomerReferenceOption] FOREIGN KEY ([InvoiceCustomerReferenceOption]) REFERENCES [Lookup].[InvoiceCustomerReferenceOption] ([Id]),
    CONSTRAINT [FK_AccountInvoicePreference_InvoiceEmailAttachmentOption] FOREIGN KEY ([PdfInvoiceEmailAttachmentOption]) REFERENCES [Lookup].[InvoiceEmailAttachmentOption] ([Id]),
    CONSTRAINT [FK_AccountInvoicePreference_InvoiceLayout] FOREIGN KEY ([LayoutId]) REFERENCES [Lookup].[InvoiceLayout] ([Id]),
    CONSTRAINT [FK_AccountInvoicePreference_InvoiceSummarizationOption] FOREIGN KEY ([InvoiceSummarizationOption]) REFERENCES [Lookup].[InvoiceSummarizationOption] ([Id]),
    CONSTRAINT [FK_AccountInvoicePreference_TrackedItemDisplayFormat] FOREIGN KEY ([TrackedItemDisplayFormatId]) REFERENCES [Lookup].[TrackedItemDisplayFormat] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_AccountInvoicePreference_InvoiceCustomerReferenceOption]
    ON [dbo].[AccountInvoicePreference]([InvoiceCustomerReferenceOption] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_AccountInvoicePreference_LayoutId]
    ON [dbo].[AccountInvoicePreference]([LayoutId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO


CREATE   TRIGGER [dbo].[trig_update_accountinvoicepreference_set_nextinvoicenumber] ON [dbo].[AccountInvoicePreference]
FOR UPDATE
AS
BEGIN

BEGIN TRAN NextInvoiceNumber

DECLARE @NextInvoiceNumber int

DECLARE @AccountId bigint

SELECT 
	@AccountId = Id,
	@NextInvoiceNumber = NextInvoiceNumber
FROM inserted

IF EXISTS(SELECT Id
FROM Invoice WITH (ROWLOCK)
WHERE AccountId = @AccountId
AND InvoiceNumber = @NextInvoiceNumber)
BEGIN

	RAISERROR (15600,-1,-1, 'Next Invoice Number already in use. Cannot update AccountInvoicePreference')
	ROLLBACK TRANSACTION

END
ELSE

	COMMIT TRANSACTION NextInvoiceNumber

END

GO

