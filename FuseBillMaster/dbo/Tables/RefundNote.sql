CREATE TABLE [dbo].[RefundNote] (
    [Id]                 BIGINT   IDENTITY (1, 1) NOT NULL,
    [CreatedTimestamp]   DATETIME NOT NULL,
    [Amount]             MONEY    NOT NULL,
    [InvoiceId]          BIGINT   NOT NULL,
    [RefundId]           BIGINT   NOT NULL,
    [EffectiveTimestamp] DATETIME NOT NULL,
    CONSTRAINT [PK_RefundNote] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_RefundNote_Invoice] FOREIGN KEY ([InvoiceId]) REFERENCES [dbo].[Invoice] ([Id]),
    CONSTRAINT [FK_RefundNote_Refund] FOREIGN KEY ([RefundId]) REFERENCES [dbo].[Refund] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_RefundNote_RefundId]
    ON [dbo].[RefundNote]([RefundId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_RefundNote_InvoiceId]
    ON [dbo].[RefundNote]([InvoiceId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

