CREATE TABLE [dbo].[AccountInvoicePreferenceDisplayField] (
    [Id]                 BIGINT NOT NULL,
    [OpeningBalance]     BIT    NOT NULL,
    [ClosingBalance]     BIT    NOT NULL,
    [InvoiceNumber]      BIT    NOT NULL,
    [InvoiceAmount]      BIT    NOT NULL,
    [PostedDate]         BIT    NOT NULL,
    [DueDate]            BIT    NOT NULL,
    [Terms]              BIT    NOT NULL,
    [OutstandingBalance] BIT    NOT NULL,
    [Status]             BIT    NOT NULL,
    [PoNumber]           BIT    NOT NULL,
    [ChildTitle]         BIT    NOT NULL,
    [ChildSubtotal]      BIT    NOT NULL,
    [ChildDiscounts]     BIT    NOT NULL,
    [ChildTaxes]         BIT    NOT NULL,
    [ChildTotal]         BIT    NOT NULL,
    [ChildDetails]       BIT    NOT NULL,
    [TaxPercentage]      BIT    CONSTRAINT [DF_TaxPercentage] DEFAULT ((1)) NOT NULL,
    [ReferenceDate]      BIT    CONSTRAINT [DF_ReferenceDate] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_AccountInvoicePreferenceDisplayField] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_AccountInvoicePreferenceDisplayField_AccountInvoicePreference] FOREIGN KEY ([Id]) REFERENCES [dbo].[AccountInvoicePreference] ([Id])
);


GO

