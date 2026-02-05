CREATE TABLE [dbo].[ProjectedInvoice] (
    [Id]                 BIGINT   IDENTITY (1, 1) NOT NULL,
    [ProjectedInvoiceId] BIGINT   NULL,
    [CustomerId]         BIGINT   NULL,
    [SumOfCharges]       MONEY    NOT NULL,
    [SumOfDiscounts]     MONEY    NOT NULL,
    [ProjectedTotal]     MONEY    NOT NULL,
    [CreatedTimestamp]   DATETIME NOT NULL,
    [EffectiveTimestamp] DATETIME NOT NULL,
    CONSTRAINT [PK_ProjectedInvoice] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_ProjectedInvoice_Customer] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([Id]),
    CONSTRAINT [FK_ProjectedInvoice_DraftInvoice] FOREIGN KEY ([ProjectedInvoiceId]) REFERENCES [dbo].[DraftInvoice] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_ProjectedInvoice_ProjectedInvoiceId]
    ON [dbo].[ProjectedInvoice]([ProjectedInvoiceId] ASC)
    INCLUDE([Id]) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_ProjectedInvoice_CustomerId_EffectiveTimestamp]
    ON [dbo].[ProjectedInvoice]([CustomerId] ASC, [EffectiveTimestamp] ASC)
    INCLUDE([Id], [ProjectedTotal]) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_ProjectedInvoice_EffectiveTimestamp]
    ON [dbo].[ProjectedInvoice]([EffectiveTimestamp] ASC)
    INCLUDE([Id], [CustomerId], [ProjectedTotal]) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

