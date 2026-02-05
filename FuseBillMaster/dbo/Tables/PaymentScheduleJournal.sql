CREATE TABLE [dbo].[PaymentScheduleJournal] (
    [Id]                 BIGINT   IDENTITY (1, 1) NOT NULL,
    [PaymentScheduleId]  BIGINT   NOT NULL,
    [DueDate]            DATETIME NOT NULL,
    [StatusId]           INT      NOT NULL,
    [OutstandingBalance] MONEY    NOT NULL,
    [CreatedTimestamp]   DATETIME NOT NULL,
    [IsActive]           BIT      NOT NULL,
    CONSTRAINT [PK_PaymentScheduleJournal] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_PaymentScheduleJournal_InvoiceStatus] FOREIGN KEY ([StatusId]) REFERENCES [Lookup].[InvoiceStatus] ([Id]),
    CONSTRAINT [FK_PaymentScheduleJournal_PaymentSchedule] FOREIGN KEY ([PaymentScheduleId]) REFERENCES [dbo].[PaymentSchedule] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_PaymentScheduleJournal_PaymentScheduleId_CreatedTimestamp]
    ON [dbo].[PaymentScheduleJournal]([PaymentScheduleId] ASC, [CreatedTimestamp] ASC)
    INCLUDE([Id], [DueDate], [OutstandingBalance], [StatusId]) WITH (FILLFACTOR = 100);


GO

CREATE NONCLUSTERED INDEX [IX_PaymentScheduleJournal_PaymentScheduleId_IsActive_StatusId_INCL]
    ON [dbo].[PaymentScheduleJournal]([PaymentScheduleId] ASC, [IsActive] ASC, [StatusId] ASC)
    INCLUDE([DueDate], [OutstandingBalance]) WITH (FILLFACTOR = 100);


GO

CREATE NONCLUSTERED INDEX [IX_PaymentScheduleJournal_CreatedTimestamp]
    ON [dbo].[PaymentScheduleJournal]([CreatedTimestamp] ASC)
    INCLUDE([Id], [PaymentScheduleId]) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_PaymentScheduleJournal_StatusId_IsActive]
    ON [dbo].[PaymentScheduleJournal]([StatusId] ASC, [IsActive] ASC)
    INCLUDE([PaymentScheduleId], [DueDate]) WITH (FILLFACTOR = 100);


GO

