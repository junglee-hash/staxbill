CREATE TABLE [dbo].[SubscriptionProductActivityJournalCharge] (
    [Id]                                   BIGINT          IDENTITY (1, 1) NOT NULL,
    [CreatedTimestamp]                     DATETIME        NOT NULL,
    [SubscriptionProductActivityJournalId] BIGINT          NOT NULL,
    [ChargeId]                             BIGINT          NOT NULL,
    [DeltaQuantity]                        DECIMAL (18, 6) NOT NULL,
    [ChargeOrder]                          INT             NOT NULL,
    CONSTRAINT [PK_SubscriptionProductActivityJournalCharge] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_SubscriptionProductActivityJournalCharge_Charge] FOREIGN KEY ([ChargeId]) REFERENCES [dbo].[Charge] ([Id]),
    CONSTRAINT [FK_SubscriptionProductActivityJournalCharge_SubscriptionProductActivityJournal] FOREIGN KEY ([SubscriptionProductActivityJournalId]) REFERENCES [dbo].[SubscriptionProductActivityJournal] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_SubscriptionProductActivityJournalCharge_ChargeId]
    ON [dbo].[SubscriptionProductActivityJournalCharge]([ChargeId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_SubscriptionProductActivityJournalCharge_SubscriptionProductActivityJournalId]
    ON [dbo].[SubscriptionProductActivityJournalCharge]([SubscriptionProductActivityJournalId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

