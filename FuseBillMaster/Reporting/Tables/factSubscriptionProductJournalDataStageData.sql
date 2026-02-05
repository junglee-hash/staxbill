CREATE TABLE [Reporting].[factSubscriptionProductJournalDataStageData] (
    [SubscriptionProductJournalId]      BIGINT          NOT NULL,
    [SubscriptionProductId]             BIGINT          NOT NULL,
    [SubscriptionStatusId]              INT             NOT NULL,
    [SubscriptionProductStatusId]       INT             NOT NULL,
    [SubscriptionProductGrossMRR]       DECIMAL (18, 2) NOT NULL,
    [SubscriptionProductNetMRR]         DECIMAL (18, 2) NOT NULL,
    [SubscriptionProductCurrentMRR]     MONEY           NOT NULL,
    [SubscriptionProductCurrentNetMRR]  MONEY           NOT NULL,
    [SubscriptionProductIncludedStatus] VARCHAR (50)    NOT NULL,
    [SubscriptionProductQuantity]       DECIMAL (18, 6) NOT NULL,
    [SubscriptionActivationDate]        DATETIME        NULL,
    [SubscriptionCancellationDate]      DATETIME        NULL,
    [SalesTrackingCode1Id]              BIGINT          NULL,
    [SalesTrackingCode2Id]              BIGINT          NULL,
    [SalesTrackingCode3Id]              BIGINT          NULL,
    [SalesTrackingCode4Id]              BIGINT          NULL,
    [SalesTrackingCode5Id]              BIGINT          NULL,
    [JournalCreatedTimestamp]           DATETIME        NOT NULL,
    [EffectiveTimestamp]                DATETIME        NOT NULL,
    [ExpiredTimestamp]                  DATETIME        NULL,
    [RemainingInterval]                 INT             NULL,
    [SubscriptionExpiryTimestamp]       DATETIME        NULL,
    [Id]                                BIGINT          IDENTITY (1, 1) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

CREATE NONCLUSTERED INDEX [IDX1]
    ON [Reporting].[factSubscriptionProductJournalDataStageData]([SubscriptionProductId] ASC, [SubscriptionStatusId] ASC) WITH (FILLFACTOR = 100);


GO

