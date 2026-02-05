CREATE TABLE [Reporting].[FactSubscriptionProduct] (
    [Id]                                BIGINT          IDENTITY (1, 1) NOT NULL,
    [ReportDate]                        DATE            NOT NULL,
    [SubscriptionProductId]             BIGINT          NOT NULL,
    [AccountId]                         BIGINT          NOT NULL,
    [CustomerId]                        BIGINT          NOT NULL,
    [SubscriptionId]                    BIGINT          NOT NULL,
    [PlanId]                            BIGINT          NOT NULL,
    [ProductId]                         BIGINT          NOT NULL,
    [IntervalName]                      VARCHAR (50)    NOT NULL,
    [NumberOfIntervals]                 INT             NOT NULL,
    [SubscriptionActivationTimestamp]   DATE            NULL,
    [SubscriptionCancellationTimestamp] DATE            NULL,
    [ProductQuantity]                   DECIMAL (18, 6) NOT NULL,
    [MRR]                               MONEY           NOT NULL,
    [Currency]                          VARCHAR (20)    NOT NULL,
    CONSTRAINT [PK_FactSubscriptionProduct] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON)
);


GO

CREATE NONCLUSTERED INDEX [ix_FactSubscriptionProduct_AccountId_CurrencyId]
    ON [Reporting].[FactSubscriptionProduct]([AccountId] ASC, [Currency] ASC)
    INCLUDE([ReportDate], [SubscriptionProductId], [PlanId], [SubscriptionCancellationTimestamp], [MRR]) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

