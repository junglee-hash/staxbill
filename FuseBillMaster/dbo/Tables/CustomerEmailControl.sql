CREATE TABLE [dbo].[CustomerEmailControl] (
    [Id]                BIGINT       IDENTITY (1, 1) NOT NULL,
    [CustomerId]        BIGINT       NOT NULL,
    [EmailKey]          VARCHAR (50) NOT NULL,
    [CreatedTimestamp]  DATETIME     NOT NULL,
    [EmailTypeId]       INT          NULL,
    [InvoiceId]         BIGINT       NULL,
    [PaymentScheduleId] BIGINT       NULL,
    [TermId]            INT          NULL,
    [Days]              INT          NULL,
    [EntityId]          BIGINT       NULL,
    CONSTRAINT [PK_EmailCommunication] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CustomerEmailControl_EmailTypeId] FOREIGN KEY ([EmailTypeId]) REFERENCES [Lookup].[EmailType] ([Id]),
    CONSTRAINT [FK_CustomerEmailControl_InvoiceId] FOREIGN KEY ([InvoiceId]) REFERENCES [dbo].[Invoice] ([Id]),
    CONSTRAINT [FK_CustomerEmailControl_PaymentScheduleId] FOREIGN KEY ([PaymentScheduleId]) REFERENCES [dbo].[PaymentSchedule] ([Id]),
    CONSTRAINT [FK_CustomerEmailControl_TermId] FOREIGN KEY ([TermId]) REFERENCES [Lookup].[Term] ([Id]),
    CONSTRAINT [FK_EmailCommunication_Customer] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([Id]),
    CONSTRAINT [UK_CustomerEmailControl_CustomerId_EmailKey] UNIQUE NONCLUSTERED ([CustomerId] ASC, [EmailKey] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON)
);


GO

CREATE NONCLUSTERED INDEX [IX_CustomerEmailControl_EmailKey_CreatedTimestamp]
    ON [dbo].[CustomerEmailControl]([EmailKey] ASC, [CreatedTimestamp] ASC)
    INCLUDE([CustomerId]) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_CustomerEmailControl_EmailTypeId]
    ON [dbo].[CustomerEmailControl]([EmailTypeId] ASC)
    INCLUDE([CustomerId], [InvoiceId], [PaymentScheduleId], [Days]);


GO

