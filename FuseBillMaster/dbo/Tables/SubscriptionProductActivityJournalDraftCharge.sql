CREATE TABLE [dbo].[SubscriptionProductActivityJournalDraftCharge] (
    [Id]                                   BIGINT          IDENTITY (1, 1) NOT NULL,
    [CreatedTimestamp]                     DATETIME        NOT NULL,
    [SubscriptionProductActivityJournalId] BIGINT          NOT NULL,
    [DraftChargeId]                        BIGINT          NOT NULL,
    [DeltaQuantity]                        DECIMAL (18, 6) NOT NULL,
    [ChargeOrder]                          INT             NOT NULL,
    CONSTRAINT [PK_SubscriptionProductActivityJournalDraftCharge] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_SubscriptionProductActivityJournalDraftCharge_DraftCharge] FOREIGN KEY ([DraftChargeId]) REFERENCES [dbo].[DraftCharge] ([Id]),
    CONSTRAINT [FK_SubscriptionProductActivityJournalDraftCharge_SubscriptionProductActivityJournal] FOREIGN KEY ([SubscriptionProductActivityJournalId]) REFERENCES [dbo].[SubscriptionProductActivityJournal] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_SubscriptionProductActivityJournalDraftCharge_DraftChargeId]
    ON [dbo].[SubscriptionProductActivityJournalDraftCharge]([DraftChargeId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_SubscriptionProductActivityJournalDraftCharge_SubscriptionProductActivityJournalId]
    ON [dbo].[SubscriptionProductActivityJournalDraftCharge]([SubscriptionProductActivityJournalId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

