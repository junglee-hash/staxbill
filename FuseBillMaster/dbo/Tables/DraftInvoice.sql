CREATE TABLE [dbo].[DraftInvoice] (
    [Id]                   BIGINT           IDENTITY (1, 1) NOT NULL,
    [CreatedTimestamp]     DATETIME         NOT NULL,
    [ModifiedTimestamp]    DATETIME         NOT NULL,
    [BillingPeriodId]      BIGINT           NULL,
    [EffectiveTimestamp]   DATETIME         NULL,
    [PoNumber]             VARCHAR (255)    NULL,
    [Subtotal]             DECIMAL (18, 6)  NOT NULL,
    [Total]                DECIMAL (18, 6)  NOT NULL,
    [CustomerId]           BIGINT           NOT NULL,
    [DraftInvoiceStatusId] TINYINT          NOT NULL,
    [AvalaraId]            UNIQUEIDENTIFIER NULL,
    [Notes]                NVARCHAR (4000)  NULL,
    [TermId]               INT              NULL,
    [ReferenceDate]        DATETIME         DEFAULT (NULL) NULL,
    [EstimatedDueDate]     DATETIME         NULL,
    [RelatedInvoiceId]     BIGINT           NULL,
    CONSTRAINT [PK_DraftInvoice] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_DraftInvoice_BillingPeriod] FOREIGN KEY ([BillingPeriodId]) REFERENCES [dbo].[BillingPeriod] ([Id]),
    CONSTRAINT [FK_DraftInvoice_Customer] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([Id]),
    CONSTRAINT [FK_DraftInvoice_DraftInvoiceStatus] FOREIGN KEY ([DraftInvoiceStatusId]) REFERENCES [Lookup].[DraftInvoiceStatus] ([Id]),
    CONSTRAINT [FK_DraftInvoice_Invoice] FOREIGN KEY ([RelatedInvoiceId]) REFERENCES [dbo].[Invoice] ([Id]),
    CONSTRAINT [FK_DraftInvoice_Term] FOREIGN KEY ([TermId]) REFERENCES [Lookup].[Term] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_DraftInvoice_CustomerId]
    ON [dbo].[DraftInvoice]([CustomerId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_DraftInvoice_DraftInvoiceStatusId]
    ON [dbo].[DraftInvoice]([DraftInvoiceStatusId] ASC)
    INCLUDE([Id], [CreatedTimestamp], [BillingPeriodId], [EffectiveTimestamp], [Total], [CustomerId]) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_DraftInvoice_BillingPeriodId]
    ON [dbo].[DraftInvoice]([BillingPeriodId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

