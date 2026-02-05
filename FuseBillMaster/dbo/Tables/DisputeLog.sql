CREATE TABLE [dbo].[DisputeLog] (
    [Id]                       BIGINT         IDENTITY (1, 1) NOT NULL,
    [AccountId]                BIGINT         NOT NULL,
    [CustomerId]               BIGINT         NOT NULL,
    [PaymentActivityJournalId] BIGINT         NOT NULL,
    [Details]                  NVARCHAR (MAX) NOT NULL,
    [CreatedTimestamp]         DATETIME       NOT NULL,
    CONSTRAINT [PK_DisputeLog] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_DisputeLog_Customer] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([Id]),
    CONSTRAINT [FK_DisputeLog_PaymentActivityJournal] FOREIGN KEY ([PaymentActivityJournalId]) REFERENCES [dbo].[PaymentActivityJournal] ([Id])
);


GO

