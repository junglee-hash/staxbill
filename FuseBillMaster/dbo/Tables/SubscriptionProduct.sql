CREATE TABLE [dbo].[SubscriptionProduct] (
    [Id]                                    BIGINT          IDENTITY (1, 1) NOT NULL,
    [CreatedTimestamp]                      DATETIME        NOT NULL,
    [ModifiedTimestamp]                     DATETIME        NOT NULL,
    [Included]                              BIT             NOT NULL,
    [PlanProductId]                         BIGINT          NOT NULL,
    [Quantity]                              DECIMAL (18, 6) NOT NULL,
    [SubscriptionId]                        BIGINT          NOT NULL,
    [StartDate]                             DATETIME        NULL,
    [ChargeAtSubscriptionActivation]        BIT             NOT NULL,
    [IsCharged]                             BIT             CONSTRAINT [DF_SubscriptionProduct_IsCharged] DEFAULT ((0)) NOT NULL,
    [IsTrackingItems]                       BIT             NOT NULL,
    [MonthlyRecurringRevenue]               MONEY           CONSTRAINT [DF_SubscriptionProduct_MonthlyRecurringRevenue] DEFAULT ((0)) NOT NULL,
    [Amount]                                MONEY           CONSTRAINT [DF_SubscriptionProductAmount] DEFAULT ((0)) NOT NULL,
    [StatusId]                              INT             NOT NULL,
    [SalesforceId]                          NVARCHAR (255)  NULL,
    [NetMRR]                                MONEY           NOT NULL,
    [MaxQuantity]                           DECIMAL (18, 6) NULL,
    [IsFixed]                               BIT             NOT NULL,
    [NetsuiteId]                            NVARCHAR (255)  NULL,
    [EarningTimingTypeId]                   INT             NOT NULL,
    [EarningTimingIntervalId]               INT             NOT NULL,
    [PlanProductName]                       NVARCHAR (100)  NOT NULL,
    [PlanProductDescription]                NVARCHAR (1000) NULL,
    [PlanProductCode]                       NVARCHAR (1000) NOT NULL,
    [PlanProductUniqueId]                   BIGINT          NOT NULL,
    [ProductId]                             BIGINT          NOT NULL,
    [ProductTypeId]                         INT             NOT NULL,
    [IsRecurring]                           BIT             NOT NULL,
    [IsOptional]                            BIT             NOT NULL,
    [IsIncludedByDefault]                   BIT             NOT NULL,
    [ResetTypeId]                           INT             NOT NULL,
    [RecurChargeTimingTypeId]               INT             NOT NULL,
    [RecurProrateGranularityId]             INT             NULL,
    [RecurProrateNegativeQuantity]          BIT             NOT NULL,
    [RecurProratePositiveQuantity]          BIT             NOT NULL,
    [RecurReverseChargeNegativeQuantity]    BIT             NOT NULL,
    [QuantityChargeTimingTypeId]            INT             NOT NULL,
    [QuantityProrateGranularityId]          INT             NULL,
    [QuantityProrateNegativeQuantity]       BIT             NOT NULL,
    [QuantityProratePositiveQuantity]       BIT             NOT NULL,
    [QuantityReverseChargeNegativeQuantity] BIT             NOT NULL,
    [PricingModelTypeId]                    INT             NOT NULL,
    [IsEarnedImmediately]                   BIT             NOT NULL,
    [EarningIntervalId]                     INT             NULL,
    [EarningNumberOfInterval]               INT             NULL,
    [RemainingInterval]                     INT             NULL,
    [ExpiredTimestamp]                      DATETIME        NULL,
    [CurrentMrr]                            MONEY           DEFAULT ((0)) NOT NULL,
    [CurrentNetMrr]                         MONEY           DEFAULT ((0)) NOT NULL,
    [GroupQuantityCharges]                  BIT             DEFAULT ((0)) NOT NULL,
    [PriceUpliftsEnabled]                   BIT             DEFAULT ((0)) NOT NULL,
    [CustomServiceDateNumberOfIntervals]    INT             CONSTRAINT [df_SpCustomServiceDateNumberOfIntervals] DEFAULT ((0)) NOT NULL,
    [CustomServiceDateIntervalId]           INT             CONSTRAINT [df_SpCustomServiceDateIntervalId] DEFAULT ((1)) NOT NULL,
    [CustomServiceDateProjectionId]         INT             CONSTRAINT [df_SpCustomServiceDateProjectionId] DEFAULT ((1)) NOT NULL,
    [UpliftPriorToRecharge]                 BIT             CONSTRAINT [df_SubscriptionProduct_UpliftPriorToRecharge] DEFAULT ((0)) NOT NULL,
    [IncludingInitialCharge]                BIT             CONSTRAINT [df_SubscriptionProduct_IncludingInitialCharge] DEFAULT ((0)) NOT NULL,
    [GenerateZeroDollarCharge]              BIT             CONSTRAINT [DF_SubscriptionProduct_GenerateZeroDollarCharge] DEFAULT ((1)) NOT NULL,
    [DigitalRiverBillingAgreementId]        VARCHAR (50)    NULL,
    [PricingFormulaTypeId]                  INT             CONSTRAINT [DF_PricingFormulaTypeIdSubscriptionProduct] DEFAULT (NULL) NULL,
    [IntervalsUntilStart]                   INT             NULL,
    [TrackPeakQuantity]                     BIT             CONSTRAINT [DF_SubscriptionProductTrackPeakQuantity] DEFAULT ((0)) NOT NULL,
    [PeakQuantity]                          DECIMAL (18, 6) NULL,
    [LastPurchaseDate]                      DATETIME        NULL,
    [PricebookId]                           BIGINT          NULL,
    CONSTRAINT [PK_SubscriptionProduct] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_SubscriptionProduct_CustomServiceDateIntervalId] FOREIGN KEY ([CustomServiceDateIntervalId]) REFERENCES [Lookup].[CustomServiceDateInterval] ([Id]),
    CONSTRAINT [FK_SubscriptionProduct_CustomServiceDateProjectionId] FOREIGN KEY ([CustomServiceDateProjectionId]) REFERENCES [Lookup].[CustomServiceDateProjection] ([Id]),
    CONSTRAINT [FK_SubscriptionProduct_EarningIntervalId] FOREIGN KEY ([EarningIntervalId]) REFERENCES [Lookup].[Interval] ([Id]),
    CONSTRAINT [FK_SubscriptionProduct_PlanProduct] FOREIGN KEY ([PlanProductId]) REFERENCES [dbo].[PlanProduct] ([Id]),
    CONSTRAINT [FK_SubscriptionProduct_PlanProductUniqueId] FOREIGN KEY ([PlanProductUniqueId]) REFERENCES [dbo].[PlanProductKey] ([Id]),
    CONSTRAINT [FK_SubscriptionProduct_Pricebook] FOREIGN KEY ([PricebookId]) REFERENCES [dbo].[Pricebook] ([Id]),
    CONSTRAINT [FK_SubscriptionProduct_PricingFormulaTypeId] FOREIGN KEY ([PricingFormulaTypeId]) REFERENCES [Lookup].[PricingFormulaType] ([Id]),
    CONSTRAINT [FK_SubscriptionProduct_PricingModelTypeId] FOREIGN KEY ([PricingModelTypeId]) REFERENCES [Lookup].[PricingModelType] ([Id]),
    CONSTRAINT [FK_SubscriptionProduct_ProductId] FOREIGN KEY ([ProductId]) REFERENCES [dbo].[Product] ([Id]),
    CONSTRAINT [FK_SubscriptionProduct_ProductTypeId] FOREIGN KEY ([ProductTypeId]) REFERENCES [Lookup].[ProductType] ([Id]),
    CONSTRAINT [FK_SubscriptionProduct_QuantityChargeTimingTypeId] FOREIGN KEY ([QuantityChargeTimingTypeId]) REFERENCES [Lookup].[ChargeTimingType] ([Id]),
    CONSTRAINT [FK_SubscriptionProduct_QuantityProrateGranularityId] FOREIGN KEY ([QuantityProrateGranularityId]) REFERENCES [Lookup].[ProrateGranularity] ([Id]),
    CONSTRAINT [FK_SubscriptionProduct_RecurChargeTimingTypeId] FOREIGN KEY ([RecurChargeTimingTypeId]) REFERENCES [Lookup].[ChargeTimingType] ([Id]),
    CONSTRAINT [FK_SubscriptionProduct_RecurProrateGranularityId] FOREIGN KEY ([RecurProrateGranularityId]) REFERENCES [Lookup].[ProrateGranularity] ([Id]),
    CONSTRAINT [FK_SubscriptionProduct_ResetTypeId] FOREIGN KEY ([ResetTypeId]) REFERENCES [Lookup].[ProductResetType] ([Id]),
    CONSTRAINT [FK_SubscriptionProduct_Subscription] FOREIGN KEY ([SubscriptionId]) REFERENCES [dbo].[Subscription] ([Id]),
    CONSTRAINT [FK_SubscriptionProduct_SubscriptionProductStatus] FOREIGN KEY ([StatusId]) REFERENCES [Lookup].[SubscriptionProductStatus] ([Id]),
    CONSTRAINT [FK_SubscriptionProductEarningTimingIntervalId_EarningTimingInterval] FOREIGN KEY ([EarningTimingIntervalId]) REFERENCES [Lookup].[EarningTimingInterval] ([Id]),
    CONSTRAINT [FK_SubscriptionProductEarningTimingTypeId_EarningTimingType] FOREIGN KEY ([EarningTimingTypeId]) REFERENCES [Lookup].[EarningTimingType] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_SubscriptionProduct_SubscriptionId_PlanProductId]
    ON [dbo].[SubscriptionProduct]([SubscriptionId] ASC, [PlanProductId] ASC)
    INCLUDE([Id], [Quantity], [StartDate]) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_SubscriptionProduct_StatusId_Included_IsCharged_INCL]
    ON [dbo].[SubscriptionProduct]([StatusId] ASC, [Included] ASC, [IsCharged] ASC)
    INCLUDE([SubscriptionId], [StartDate]) WITH (FILLFACTOR = 100);


GO

CREATE NONCLUSTERED INDEX [IX_SubscriptionProduct_IsCharged_StartDate]
    ON [dbo].[SubscriptionProduct]([IsCharged] ASC, [StartDate] ASC)
    INCLUDE([SubscriptionId]) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_SubscriptionProduct_SubscriptionId_StatusId]
    ON [dbo].[SubscriptionProduct]([SubscriptionId] ASC, [StatusId] ASC) WITH (FILLFACTOR = 100);


GO

CREATE NONCLUSTERED INDEX [IX_SubscriptionProduct_SubscriptionId_Included_ProductId_INCL]
    ON [dbo].[SubscriptionProduct]([SubscriptionId] ASC, [Included] ASC, [ProductId] ASC)
    INCLUDE([Quantity], [PlanProductUniqueId]) WITH (FILLFACTOR = 100);


GO

CREATE NONCLUSTERED INDEX [IX_SubscriptionProduct_ModifiedTimestamp]
    ON [dbo].[SubscriptionProduct]([ModifiedTimestamp] ASC) WITH (FILLFACTOR = 100);


GO

CREATE NONCLUSTERED INDEX [FKIX_SubscriptionProduct_ProductId]
    ON [dbo].[SubscriptionProduct]([ProductId] ASC) WITH (FILLFACTOR = 100);


GO

