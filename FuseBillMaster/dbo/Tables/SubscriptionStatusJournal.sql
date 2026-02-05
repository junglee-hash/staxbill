CREATE TABLE [dbo].[SubscriptionStatusJournal] (
    [Id]               BIGINT   IDENTITY (1, 1) NOT NULL,
    [SubscriptionId]   BIGINT   NOT NULL,
    [StatusId]         INT      NOT NULL,
    [CreatedTimestamp] DATETIME NOT NULL,
    [SequenceNumber]   INT      NOT NULL,
    CONSTRAINT [PK_SubscriptionStatusJournal] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_SubscriptionStatusJournal_Subscription] FOREIGN KEY ([SubscriptionId]) REFERENCES [dbo].[Subscription] ([Id]),
    CONSTRAINT [FK_SubscriptionStatusJournal_SubscriptionStatus] FOREIGN KEY ([StatusId]) REFERENCES [Lookup].[SubscriptionStatus] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_SubscriptionStatusJournal_CreatedTimestamp]
    ON [dbo].[SubscriptionStatusJournal]([CreatedTimestamp] ASC)
    INCLUDE([Id], [SubscriptionId], [SequenceNumber]) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_SubscriptionStatusJournal_StatusId]
    ON [dbo].[SubscriptionStatusJournal]([StatusId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_SubscriptionStatusJournal_SubscriptionId]
    ON [dbo].[SubscriptionStatusJournal]([SubscriptionId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

