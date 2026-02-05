CREATE TABLE [dbo].[CustomerAccountStatusJournal] (
    [Id]                 BIGINT   IDENTITY (1, 1) NOT NULL,
    [CustomerId]         BIGINT   NOT NULL,
    [StatusId]           INT      NOT NULL,
    [CreatedTimestamp]   DATETIME NOT NULL,
    [IsActive]           BIT      NOT NULL,
    [SequenceNumber]     INT      NOT NULL,
    [EffectiveTimestamp] DATETIME NOT NULL,
    CONSTRAINT [PK_CustomerAccountStatusJournal] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CustomerAccountStatusJournal_Customer] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([Id]) ON DELETE CASCADE,
    CONSTRAINT [FK_CustomerAccountStatusJournal_CustomerAccountStatus] FOREIGN KEY ([StatusId]) REFERENCES [Lookup].[CustomerAccountStatus] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_CustomerAccountStatusJournal_CustomerId]
    ON [dbo].[CustomerAccountStatusJournal]([CustomerId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_CustomerAccountStatusJournal_CreatedTimestamp]
    ON [dbo].[CustomerAccountStatusJournal]([CreatedTimestamp] ASC)
    INCLUDE([Id], [CustomerId]) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_CustomerAccountStatusJournal_StatusId_IsActive]
    ON [dbo].[CustomerAccountStatusJournal]([StatusId] ASC, [IsActive] ASC)
    INCLUDE([CustomerId], [CreatedTimestamp]) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE UNIQUE NONCLUSTERED INDEX [uk_CustomerAccountStatusJournal_CustomerId_IsActive]
    ON [dbo].[CustomerAccountStatusJournal]([CustomerId] ASC, [IsActive] ASC) WHERE ([IsActive]=(1)) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_CustomerAccountStatusJournal_EffectiveTimestamp_Customer]
    ON [dbo].[CustomerAccountStatusJournal]([EffectiveTimestamp] ASC, [CustomerId] ASC)
    INCLUDE([Id], [SequenceNumber]);


GO

