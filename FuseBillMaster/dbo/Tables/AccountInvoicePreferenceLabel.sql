CREATE TABLE [dbo].[AccountInvoicePreferenceLabel] (
    [Id]                         BIGINT        IDENTITY (1, 1) NOT NULL,
    [AccountInvoicePreferenceId] BIGINT        NOT NULL,
    [InvoicePreferenceLabelId]   INT           NOT NULL,
    [Label]                      NVARCHAR (50) NOT NULL,
    [ModifiedTimestamp]          DATETIME      NOT NULL,
    [ShowField]                  BIT           CONSTRAINT [DF_ShowField] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_AccountInvoicePreferenceLabel] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_AccountInvoicePreferenceLabel_AccountInvoicePreference] FOREIGN KEY ([AccountInvoicePreferenceId]) REFERENCES [dbo].[AccountInvoicePreference] ([Id]),
    CONSTRAINT [FK_AccountInvoicePreferenceLabel_InvoicePreferenceLabel] FOREIGN KEY ([InvoicePreferenceLabelId]) REFERENCES [Lookup].[InvoicePreferenceLabel] ([Id]),
    CONSTRAINT [UC_AccountInvoicePreferenceLabel_AccountInvoicePreferenceId_InvoicePreferenceLabelId] UNIQUE NONCLUSTERED ([AccountInvoicePreferenceId] ASC, [InvoicePreferenceLabelId] ASC) WITH (FILLFACTOR = 100)
);


GO

CREATE NONCLUSTERED INDEX [IX_AccountInvoicePreferenceLabel_AccountInvoicePreferenceId]
    ON [dbo].[AccountInvoicePreferenceLabel]([AccountInvoicePreferenceId] ASC) WITH (FILLFACTOR = 100);


GO

