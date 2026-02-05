CREATE TABLE [dbo].[PaymentSchedule] (
    [Id]                   BIGINT   IDENTITY (1, 1) NOT NULL,
    [InvoiceId]            BIGINT   NOT NULL,
    [Amount]               MONEY    NOT NULL,
    [DaysDueAfterTerm]     INT      NOT NULL,
    [CreatedTimestamp]     DATETIME NOT NULL,
    [IsDefault]            BIT      CONSTRAINT [DF_PaymentSchedule_IsDefault] DEFAULT ((1)) NOT NULL,
    [InstallmentNumber]    INT      DEFAULT ((1)) NOT NULL,
    [ScheduledDueDate]     DATETIME NULL,
    [DueDate]              DATETIME NOT NULL,
    [StatusId]             INT      NOT NULL,
    [OutstandingBalance]   MONEY    NOT NULL,
    [LastJournalTimestamp] DATETIME NOT NULL,
    CONSTRAINT [PK_PaymentSchedule] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_PaymentSchedule_Invoice] FOREIGN KEY ([InvoiceId]) REFERENCES [dbo].[Invoice] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_PaymentSchedule_LastJournalTimestamp_StatusId]
    ON [dbo].[PaymentSchedule]([LastJournalTimestamp] ASC, [StatusId] ASC)
    INCLUDE([InvoiceId], [Id], [DueDate]);


GO

CREATE NONCLUSTERED INDEX [IX_PaymentSchedule_IsDefault_InvoiceId]
    ON [dbo].[PaymentSchedule]([IsDefault] ASC, [InvoiceId] ASC) WITH (FILLFACTOR = 100);


GO

CREATE NONCLUSTERED INDEX [IX_PaymentSchedule_InvoiceId_DaysDue_Incl]
    ON [dbo].[PaymentSchedule]([InvoiceId] ASC, [DaysDueAfterTerm] ASC, [Id] ASC)
    INCLUDE([OutstandingBalance], [StatusId]);


GO

