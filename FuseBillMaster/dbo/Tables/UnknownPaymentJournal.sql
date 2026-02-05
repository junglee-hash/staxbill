CREATE TABLE [dbo].[UnknownPaymentJournal] (
    [PaymentActivityJournalId] BIGINT         NOT NULL,
    [AccountId]                BIGINT         NOT NULL,
    [CreatedTimestamp]         DATETIME       NOT NULL,
    [EffectiveTimestamp]       DATETIME       NOT NULL,
    [GatewayId]                BIGINT         NULL,
    [GatewayName]              NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_UnknownPaymentJournal] PRIMARY KEY CLUSTERED ([PaymentActivityJournalId] ASC) WITH (FILLFACTOR = 100)
);


GO

