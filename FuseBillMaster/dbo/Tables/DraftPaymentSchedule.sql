CREATE TABLE [dbo].[DraftPaymentSchedule] (
    [Id]                BIGINT   IDENTITY (1, 1) NOT NULL,
    [DraftInvoiceId]    BIGINT   NOT NULL,
    [Amount]            MONEY    NOT NULL,
    [DaysDueAfterTerm]  INT      NOT NULL,
    [CreatedTimestamp]  DATETIME NOT NULL,
    [ModifiedTimestamp] DATETIME NOT NULL,
    [ScheduledDueDate]  DATETIME NULL,
    CONSTRAINT [PK_DraftPaymentSchedule] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_DraftPaymentSchedule_DraftInvoice] FOREIGN KEY ([DraftInvoiceId]) REFERENCES [dbo].[DraftInvoice] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_DraftPaymentSchedule_DraftInvoiceId]
    ON [dbo].[DraftPaymentSchedule]([DraftInvoiceId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

