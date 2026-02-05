CREATE TABLE [dbo].[PlanOrderToCashCycle] (
    [Id]                                    BIGINT NOT NULL,
    [PlanProductId]                         BIGINT NOT NULL,
    [PlanFrequencyId]                       BIGINT NOT NULL,
    [RecurChargeTimingTypeId]               INT    NOT NULL,
    [RecurProrateGranularityId]             INT    NULL,
    [RecurProrateNegativeQuantity]          BIT    NOT NULL,
    [RecurProratePositiveQuantity]          BIT    NOT NULL,
    [RecurReverseChargeNegativeQuantity]    BIT    NOT NULL,
    [QuantityChargeTimingTypeId]            INT    NOT NULL,
    [QuantityProrateGranularityId]          INT    NULL,
    [QuantityProrateNegativeQuantity]       BIT    NOT NULL,
    [QuantityProratePositiveQuantity]       BIT    NOT NULL,
    [QuantityReverseChargeNegativeQuantity] BIT    NOT NULL,
    [RemainingInterval]                     INT    NULL,
    [PlanFrequencyUniqueId]                 BIGINT NOT NULL,
    [GroupQuantityCharges]                  BIT    DEFAULT ((0)) NOT NULL,
    [CustomServiceDateNumberOfIntervals]    INT    CONSTRAINT [df_PotcCustomServiceDateNumberOfIntervals] DEFAULT ((0)) NOT NULL,
    [CustomServiceDateIntervalId]           INT    CONSTRAINT [df_PotcCustomServiceDateIntervalId] DEFAULT ((1)) NOT NULL,
    [CustomServiceDateProjectionId]         INT    CONSTRAINT [df_PotcCustomServiceDateProjectionId] DEFAULT ((1)) NOT NULL,
    [UpliftPriorToRecharge]                 BIT    CONSTRAINT [df_PlanOrderToCashCycle_UpliftPriorToRecharge] DEFAULT ((0)) NOT NULL,
    [IncludingInitialCharge]                BIT    CONSTRAINT [df_PlanOrderToCashCycle_IncludingInitialCharge] DEFAULT ((0)) NOT NULL,
    [IntervalsUntilStart]                   INT    NULL,
    [TrackPeakQuantity]                     BIT    CONSTRAINT [DF_PlanOrderToCashCycleTrackPeakQuantity] DEFAULT ((0)) NOT NULL,
    [PricebookId]                           BIGINT NULL,
    CONSTRAINT [PK_PlanOrderToCashCycle] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_PlanOrderToCashCycle_CustomServiceDateIntervalId] FOREIGN KEY ([CustomServiceDateIntervalId]) REFERENCES [Lookup].[CustomServiceDateInterval] ([Id]),
    CONSTRAINT [FK_PlanOrderToCashCycle_CustomServiceDateProjectionId] FOREIGN KEY ([CustomServiceDateProjectionId]) REFERENCES [Lookup].[CustomServiceDateProjection] ([Id]),
    CONSTRAINT [FK_PlanOrderToCashCycle_OrderToCashCycle] FOREIGN KEY ([Id]) REFERENCES [dbo].[OrderToCashCycle] ([Id]),
    CONSTRAINT [fk_PlanOrderToCashCycle_PlanFrequencyUniqueId] FOREIGN KEY ([PlanFrequencyUniqueId]) REFERENCES [dbo].[PlanFrequencyKey] ([Id]),
    CONSTRAINT [FK_PlanOrderToCashCycle_Pricebook] FOREIGN KEY ([PricebookId]) REFERENCES [dbo].[Pricebook] ([Id]),
    CONSTRAINT [FK_PlanOrderToCashCycle_QuantityChargeTimingType] FOREIGN KEY ([QuantityChargeTimingTypeId]) REFERENCES [Lookup].[ChargeTimingType] ([Id]),
    CONSTRAINT [FK_PlanOrderToCashCycle_QuantityProrateGranularity] FOREIGN KEY ([QuantityProrateGranularityId]) REFERENCES [Lookup].[ProrateGranularity] ([Id]),
    CONSTRAINT [FK_PlanOrderToCashCycle_RecurChargeTimingType] FOREIGN KEY ([RecurChargeTimingTypeId]) REFERENCES [Lookup].[ChargeTimingType] ([Id]),
    CONSTRAINT [FK_PlanOrderToCashCycle_RecurProrateGranularity] FOREIGN KEY ([RecurProrateGranularityId]) REFERENCES [Lookup].[ProrateGranularity] ([Id]),
    CONSTRAINT [FK_PlanOrderToCashCyclePlanProductId_PlanProduct] FOREIGN KEY ([PlanProductId]) REFERENCES [dbo].[PlanProduct] ([Id]),
    CONSTRAINT [FK_PlanOrderToCashCyclePriceIntervalId_PriceInterval] FOREIGN KEY ([PlanFrequencyId]) REFERENCES [dbo].[PlanFrequency] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_PlanOrderToCashCycle_RecurProrateGranularityId]
    ON [dbo].[PlanOrderToCashCycle]([RecurProrateGranularityId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_PlanOrderToCashCycle_QuantityChargeTimingTypeId]
    ON [dbo].[PlanOrderToCashCycle]([QuantityChargeTimingTypeId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_PlanOrderToCashCycle_PlanFrequencyId]
    ON [dbo].[PlanOrderToCashCycle]([PlanFrequencyId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_PlanOrderToCashCycle_QuantityProrateGranularityId]
    ON [dbo].[PlanOrderToCashCycle]([QuantityProrateGranularityId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_PlanOrderToCashCycle_PlanProductId]
    ON [dbo].[PlanOrderToCashCycle]([PlanProductId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_PlanOrderToCashCycle_RecurChargeTimingTypeId]
    ON [dbo].[PlanOrderToCashCycle]([RecurChargeTimingTypeId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

