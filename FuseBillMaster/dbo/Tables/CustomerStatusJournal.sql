CREATE TABLE [dbo].[CustomerStatusJournal] (
    [Id]                 BIGINT   IDENTITY (1, 1) NOT NULL,
    [CustomerId]         BIGINT   NOT NULL,
    [StatusId]           INT      NOT NULL,
    [CreatedTimestamp]   DATETIME NOT NULL,
    [IsActive]           BIT      NOT NULL,
    [SequenceNumber]     INT      NOT NULL,
    [EffectiveTimestamp] DATETIME NOT NULL,
    CONSTRAINT [PK_CustomerStatusJournal] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CustomerStatusJournal_Customer] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([Id]),
    CONSTRAINT [FK_CustomerStatusJournal_CustomerStatus] FOREIGN KEY ([StatusId]) REFERENCES [Lookup].[CustomerStatus] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_CustomerStatusJournal_CustomerId]
    ON [dbo].[CustomerStatusJournal]([CustomerId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_CustomerStatusJournal_IsActive]
    ON [dbo].[CustomerStatusJournal]([IsActive] ASC)
    INCLUDE([Id], [CustomerId], [StatusId], [CreatedTimestamp], [SequenceNumber]) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_CustomerStatusJournal_StatusId_IsActive]
    ON [dbo].[CustomerStatusJournal]([StatusId] ASC, [IsActive] ASC)
    INCLUDE([CustomerId]) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE UNIQUE NONCLUSTERED INDEX [uk_CustomerStatusJournal_CustomerId_IsActive]
    ON [dbo].[CustomerStatusJournal]([CustomerId] ASC, [IsActive] ASC) WHERE ([IsActive]=(1)) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

