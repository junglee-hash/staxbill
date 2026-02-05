CREATE TABLE [dbo].[CustomerEmailLogBillingStatement] (
    [Id]                 BIGINT IDENTITY (1, 1) NOT NULL,
    [CustomerEmailLogId] BIGINT NOT NULL,
    [BillingStatementId] BIGINT NOT NULL,
    CONSTRAINT [PK_CustomerEmailLogBillingStatement] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CustomerEmailLogBillingStatement_BillingStatement] FOREIGN KEY ([BillingStatementId]) REFERENCES [dbo].[BillingStatement] ([Id]),
    CONSTRAINT [FK_CustomerEmailLogBillingStatement_CustomerEmailLog] FOREIGN KEY ([CustomerEmailLogId]) REFERENCES [dbo].[CustomerEmailLog] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_CustomerEmailLogBillingStatement_BillingStatementId]
    ON [dbo].[CustomerEmailLogBillingStatement]([BillingStatementId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_CustomerEmailLogBillingStatement_CustomerEmailLogId]
    ON [dbo].[CustomerEmailLogBillingStatement]([CustomerEmailLogId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

