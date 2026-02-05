CREATE TABLE [dbo].[SubscriptionProductActivityJournal] (
    [Id]                    BIGINT          IDENTITY (1, 1) NOT NULL,
    [SubscriptionProductId] BIGINT          NOT NULL,
    [CreatedTimestamp]      DATETIME        NOT NULL,
    [DeltaQuantity]         DECIMAL (18, 6) NOT NULL,
    [TotalQuantity]         DECIMAL (18, 6) NOT NULL,
    [Prorated]              BIT             NOT NULL,
    [Description]           NVARCHAR (1000) NULL,
    [HasCompleted]          BIT             NOT NULL,
    [EndOfPeriodCharge]     BIT             NOT NULL,
    [EndOfPeriodDate]       DATETIME        NULL,
    [TargetDay]             INT             NULL,
    [UseCreatedTimestamp]   BIT             NULL,
    CONSTRAINT [pk_SubscriptionProductQuantityChangeJournal] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [fk_SubscriptionProductQuantityChangeJournal_ID] FOREIGN KEY ([SubscriptionProductId]) REFERENCES [dbo].[SubscriptionProduct] ([Id]) ON DELETE CASCADE
);


GO

CREATE NONCLUSTERED INDEX [IX_SubscriptionProductActivityJournal_SubscriptionProductId_HasCompleted]
    ON [dbo].[SubscriptionProductActivityJournal]([SubscriptionProductId] ASC, [HasCompleted] ASC);


GO

