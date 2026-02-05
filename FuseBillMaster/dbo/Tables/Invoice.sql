CREATE TABLE [dbo].[Invoice] (
    [Id]                             BIGINT           IDENTITY (1, 1) NOT NULL,
    [AccountId]                      BIGINT           NOT NULL,
    [InvoiceNumber]                  INT              NOT NULL,
    [BillingPeriodId]                BIGINT           NULL,
    [DraftInvoiceId]                 BIGINT           NOT NULL,
    [CreatedTimestamp]               DATETIME         NOT NULL,
    [PostedTimestamp]                DATETIME         NOT NULL,
    [EffectiveTimestamp]             DATETIME         NOT NULL,
    [PoNumber]                       VARCHAR (255)    NULL,
    [SalesforceId]                   NVARCHAR (255)   NULL,
    [CustomerId]                     BIGINT           NOT NULL,
    [AvalaraId]                      UNIQUEIDENTIFIER NULL,
    [Notes]                          NVARCHAR (4000)  NULL,
    [InvoiceCustomerReferenceOption] INT              DEFAULT ((2)) NOT NULL,
    [OpeningArBalance]               MONEY            NULL,
    [ClosingArBalance]               MONEY            NULL,
    [TotalInstallments]              INT              DEFAULT ((1)) NOT NULL,
    [QuickBooksId]                   BIGINT           NULL,
    [QuickBooksAttemptNumber]        INT              DEFAULT ((0)) NOT NULL,
    [TermId]                         INT              NULL,
    [NetsuiteId]                     NVARCHAR (255)   NULL,
    [ErpNetsuiteId]                  NVARCHAR (255)   NULL,
    [DigitalRiverUpstreamId]         VARCHAR (50)     NULL,
    [HideOnSSP]                      BIT              CONSTRAINT [DF_HideOnSSP] DEFAULT ((0)) NOT NULL,
    [InvoiceSignatureId]             BIGINT           NULL,
    [Signature]                      NVARCHAR (MAX)   NULL,
    [IsQuickBooksRequeue]            BIT              NULL,
    [IsQuickBooksBlock]              BIT              NULL,
    [NumberOfInstallments]           INT              NOT NULL,
    [SumOfCharges]                   MONEY            NOT NULL,
    [SumOfPayments]                  MONEY            NOT NULL,
    [SumOfRefunds]                   MONEY            NOT NULL,
    [SumOfCreditNotes]               MONEY            NOT NULL,
    [SumOfWriteOffs]                 MONEY            NOT NULL,
    [OutstandingBalance]             MONEY            NOT NULL,
    [LastJournalTimestamp]           DATETIME         NOT NULL,
    [SumOfTaxes]                     MONEY            NOT NULL,
    [SumOfDiscounts]                 MONEY            NOT NULL,
    [DatePaid]                       DATETIME         NULL,
    [ReferenceDate]                  DATETIME         DEFAULT (NULL) NULL,
    [SageIntacctId]                  BIGINT           NULL,
    [SageIntacctAttemptNumber]       INT              CONSTRAINT [DF_InvoiceSageIntacctAttemptNumber] DEFAULT ((0)) NOT NULL,
    [TaxesCommitted]                 BIT              CONSTRAINT [DF_TaxesCommitted] DEFAULT ((0)) NOT NULL,
    [AnrokPartialTransactionId]      UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_Invoice] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_Invoice_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id]),
    CONSTRAINT [FK_Invoice_BillingPeriod] FOREIGN KEY ([BillingPeriodId]) REFERENCES [dbo].[BillingPeriod] ([Id]),
    CONSTRAINT [FK_Invoice_Customer] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([Id]),
    CONSTRAINT [FK_Invoice_InvoiceSignature] FOREIGN KEY ([InvoiceSignatureId]) REFERENCES [dbo].[InvoiceSignature] ([Id]),
    CONSTRAINT [FK_Invoice_Term] FOREIGN KEY ([TermId]) REFERENCES [Lookup].[Term] ([Id]),
    CONSTRAINT [UK_Invoice_AccountId_InvoiceNumber] UNIQUE NONCLUSTERED ([AccountId] ASC, [InvoiceNumber] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON)
);


GO

CREATE NONCLUSTERED INDEX [IX_Invoice_AccountId_EffectiveTimestamp]
    ON [dbo].[Invoice]([AccountId] ASC, [EffectiveTimestamp] ASC)
    INCLUDE([Id], [PostedTimestamp], [CustomerId]) WITH (FILLFACTOR = 100);


GO

CREATE NONCLUSTERED INDEX [FKIX_Invoice_CustomerId]
    ON [dbo].[Invoice]([CustomerId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_Invoice_BillingPeriodId]
    ON [dbo].[Invoice]([BillingPeriodId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_Invoice_AccountId_CreatedTimestamp]
    ON [dbo].[Invoice]([AccountId] ASC, [CreatedTimestamp] ASC)
    INCLUDE([Id]) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_Invoice_LastJournalTimestamp]
    ON [dbo].[Invoice]([LastJournalTimestamp] ASC)
    INCLUDE([Id]);


GO

CREATE NONCLUSTERED INDEX [IX_Invoice_AccountId_CustomerId_EffectiveTimestamp_PostedTimestamp_InvoiceNumber]
    ON [dbo].[Invoice]([AccountId] ASC, [CustomerId] ASC, [EffectiveTimestamp] ASC, [PostedTimestamp] ASC, [InvoiceNumber] ASC) WITH (FILLFACTOR = 100);


GO

CREATE NONCLUSTERED INDEX [COVIX_Invoice_Account_PoNumber_PostedTimestamp]
    ON [dbo].[Invoice]([AccountId] ASC, [PoNumber] ASC, [PostedTimestamp] ASC)
    INCLUDE([InvoiceNumber], [DraftInvoiceId], [EffectiveTimestamp], [CustomerId], [AvalaraId], [TotalInstallments], [QuickBooksId], [QuickBooksAttemptNumber], [HideOnSSP], [SumOfCharges], [SumOfPayments], [SumOfRefunds], [SumOfCreditNotes], [SumOfWriteOffs], [LastJournalTimestamp], [SumOfTaxes], [SumOfDiscounts]);


GO

/*********************************************************************************
[]

Work:
Updates the inserted record with the next invoice number

Outputs:
Invoice ID and Invoice Number


*********************************************************************************/
CREATE TRIGGER [dbo].[trig_insert_invoice_set_number] ON [dbo].[Invoice]
FOR INSERT
AS
BEGIN

BEGIN TRAN InvoiceNumber

DECLARE @InvoiceNumber int

DECLARE @AccountId bigint, @Id bigint

SELECT 
	@AccountId = AccountId
	,@Id = Id
FROM inserted

SELECT @InvoiceNumber = NextInvoiceNumber
FROM AccountInvoicePreference WITH (ROWLOCK)
WHERE Id = @AccountId

UPDATE AccountInvoicePreference
SET NextInvoiceNumber = NextInvoiceNumber + 1
WHERE Id = @AccountId

UPDATE Invoice
SET InvoiceNumber = @InvoiceNumber
WHERE Id = @Id

COMMIT TRAN InvoiceNumber

END

GO

