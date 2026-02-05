CREATE TABLE [dbo].[SubscriptionProductJournal] (
    [Id]                                 BIGINT          IDENTITY (1, 1) NOT NULL,
    [SubscriptionProductId]              BIGINT          NOT NULL,
    [SubscriptionProductGrossMRR]        DECIMAL (18, 2) NOT NULL,
    [SubscriptionProductNetMRR]          DECIMAL (18, 2) NOT NULL,
    [SubscriptionProductIncludedStatus]  VARCHAR (50)    NOT NULL,
    [SubscriptionProductQuantity]        DECIMAL (18, 6) NOT NULL,
    [SubscriptionProductAmount]          DECIMAL (18, 2) NOT NULL,
    [SubscriptionStatusId]               INT             NOT NULL,
    [SubscriptionActivationDate]         DATETIME        NULL,
    [SubscriptionCancellationDate]       DATETIME        NULL,
    [SubscriptionContractStartTimestamp] DATETIME        NULL,
    [SubscriptionContractEndTimestamp]   DATETIME        NULL,
    [SalesTrackingCode1Id]               BIGINT          NULL,
    [SalesTrackingCode2Id]               BIGINT          NULL,
    [SalesTrackingCode3Id]               BIGINT          NULL,
    [SalesTrackingCode4Id]               BIGINT          NULL,
    [SalesTrackingCode5Id]               BIGINT          NULL,
    [CreatedTimestamp]                   DATETIME        NOT NULL,
    [RemainingInterval]                  INT             NULL,
    [ExpiredTimestamp]                   DATETIME        NULL,
    [SubscriptionProductStatusId]        INT             DEFAULT ((1)) NOT NULL,
    [SubscriptionProductCurrentMrr]      MONEY           DEFAULT ((0)) NOT NULL,
    [SubscriptionProductCurrentNetMrr]   MONEY           DEFAULT ((0)) NOT NULL,
    [EffectiveTimestamp]                 DATETIME        NOT NULL,
    [SubscriptionExpiryTimestamp]        DATETIME        NULL,
    [JournalYear]                        AS              (datepart(year,[CreatedTimestamp])),
    [JournalMonth]                       AS              (datepart(month,[CreatedTimestamp])),
    CONSTRAINT [pk_SubscriptionProductJournal] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON, DATA_COMPRESSION = PAGE)
);


GO

CREATE NONCLUSTERED INDEX [IX_SubscriptionProductJournal_YearMonth]
    ON [dbo].[SubscriptionProductJournal]([JournalYear] ASC, [JournalMonth] ASC)
    INCLUDE([Id], [SubscriptionProductId], [CreatedTimestamp]);


GO

CREATE NONCLUSTERED INDEX [IX_SubscriptionProductJournal_CreatedTimestamp]
    ON [dbo].[SubscriptionProductJournal]([SubscriptionProductId] ASC, [CreatedTimestamp] ASC)
    INCLUDE([Id]) WITH (FILLFACTOR = 100);


GO

CREATE NONCLUSTERED INDEX [IX_SubscriptionProductJournal_SubscriptionProductId]
    ON [dbo].[SubscriptionProductJournal]([SubscriptionProductId] ASC)
    INCLUDE([Id]) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

