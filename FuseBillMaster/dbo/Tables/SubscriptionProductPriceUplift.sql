CREATE TABLE [dbo].[SubscriptionProductPriceUplift] (
    [Id]                    BIGINT          IDENTITY (1, 1) NOT NULL,
    [SubscriptionProductId] BIGINT          NOT NULL,
    [SequenceNumber]        INT             NOT NULL,
    [NumberOfIntervals]     INT             NOT NULL,
    [RemainingIntervals]    INT             NOT NULL,
    [Amount]                DECIMAL (18, 6) NOT NULL,
    [RepeatForever]         BIT             NOT NULL,
    [IsConsumed]            BIT             NOT NULL,
    [IsCurrent]             BIT             NOT NULL,
    [ConsumedTimestamp]     DATETIME        NULL,
    [OriginalAmount]        MONEY           NULL,
    [IncreasedAmount]       MONEY           NULL,
    [UpliftPriorToRecharge] BIT             NOT NULL,
    [UpliftTypeId]          TINYINT         CONSTRAINT [DF_SubscriptionProductPriceUplift_UpliftTypeId] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_SubscriptionProductPriceUplift] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_SubscriptionProductPriceUplift_SubscriptionProduct] FOREIGN KEY ([SubscriptionProductId]) REFERENCES [dbo].[SubscriptionProduct] ([Id]),
    CONSTRAINT [FK_SubscriptionProductPriceUplift_UpliftTypeId] FOREIGN KEY ([UpliftTypeId]) REFERENCES [Lookup].[UpliftType] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_SubscriptionProductPriceUplift_SubscriptionProductId_IsConsumed_IsCurrent_SequenceNumber]
    ON [dbo].[SubscriptionProductPriceUplift]([SubscriptionProductId] ASC, [IsConsumed] ASC, [IsCurrent] ASC, [SequenceNumber] ASC) WITH (FILLFACTOR = 100);


GO

