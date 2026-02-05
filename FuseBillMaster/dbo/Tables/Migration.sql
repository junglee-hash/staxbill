CREATE TABLE [dbo].[Migration] (
    [Id]                          BIGINT   IDENTITY (1, 1) NOT NULL,
    [FusebillId]                  BIGINT   NOT NULL,
    [RelationshipId]              BIGINT   NOT NULL,
    [SourcePlanFrequencyId]       BIGINT   NOT NULL,
    [DestinationPlanFrequencyId]  BIGINT   NOT NULL,
    [RelationshipMigrationTypeId] INT      NOT NULL,
    [SourceSubscriptionId]        BIGINT   NOT NULL,
    [DestinationSubscriptionId]   BIGINT   NOT NULL,
    [EffectiveTimestamp]          DATETIME CONSTRAINT [DF_effectivetimestamp] DEFAULT (getutcdate()) NOT NULL,
    [SourceCurrentMRR]            MONEY    CONSTRAINT [DF_SourceCurrentMRR] DEFAULT ((0)) NOT NULL,
    [SourceCurrentNetMRR]         MONEY    CONSTRAINT [DF_SourceCurrentNetMRR] DEFAULT ((0)) NOT NULL,
    [SourceCommittedMRR]          MONEY    CONSTRAINT [DF_SourceCommittedMRR] DEFAULT ((0)) NOT NULL,
    [SourceCommittedNetMRR]       MONEY    CONSTRAINT [DF_SourceCommittedNetMRR] DEFAULT ((0)) NOT NULL,
    [DestinationCurrentMRR]       MONEY    CONSTRAINT [DF_DestinationCurrentMRR] DEFAULT ((0)) NOT NULL,
    [DestinationCurrentNetMRR]    MONEY    CONSTRAINT [DF_DestinationCurrentNetMRR] DEFAULT ((0)) NOT NULL,
    [DestinationCommittedMRR]     MONEY    CONSTRAINT [DF_DestinationCommittedMRR] DEFAULT ((0)) NOT NULL,
    [DestinationCommittedNetMRR]  MONEY    CONSTRAINT [DF_DestinationCommittedNetMRR] DEFAULT ((0)) NOT NULL,
    [MigrationTimingOptionId]     INT      CONSTRAINT [df_SmMigrationTimingOptionId] DEFAULT ((1)) NOT NULL,
    [EarningOptionId]             INT      CONSTRAINT [df_MigrationEarningOptionId] DEFAULT ((1)) NOT NULL,
    [CouponCodeId]                BIGINT   NULL,
    CONSTRAINT [PK_Migration] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_Migration_CouponCode] FOREIGN KEY ([CouponCodeId]) REFERENCES [dbo].[CouponCode] ([Id]),
    CONSTRAINT [FK_Migration_DestinationPlanFrequencyId] FOREIGN KEY ([DestinationPlanFrequencyId]) REFERENCES [dbo].[PlanFrequency] ([Id]),
    CONSTRAINT [FK_Migration_DestinationSubscriptionId] FOREIGN KEY ([DestinationSubscriptionId]) REFERENCES [dbo].[Subscription] ([Id]),
    CONSTRAINT [FK_Migration_EarningOptionId] FOREIGN KEY ([EarningOptionId]) REFERENCES [Lookup].[SubscriptionCancellationReversalOptions] ([Id]),
    CONSTRAINT [FK_Migration_FusebillId] FOREIGN KEY ([FusebillId]) REFERENCES [dbo].[Customer] ([Id]),
    CONSTRAINT [FK_Migration_MigrationTimingOption] FOREIGN KEY ([MigrationTimingOptionId]) REFERENCES [Lookup].[MigrationTimingOptions] ([Id]),
    CONSTRAINT [FK_Migration_RelationshipId] FOREIGN KEY ([RelationshipId]) REFERENCES [dbo].[PlanFamilyRelationship] ([Id]),
    CONSTRAINT [FK_Migration_RelationshipMigrationTypeId] FOREIGN KEY ([RelationshipMigrationTypeId]) REFERENCES [Lookup].[RelationshipMigrationType] ([Id]),
    CONSTRAINT [FK_Migration_SourcePlanFrequencyId] FOREIGN KEY ([SourcePlanFrequencyId]) REFERENCES [dbo].[PlanFrequency] ([Id]),
    CONSTRAINT [FK_Migration_SourceSubscriptionId] FOREIGN KEY ([SourceSubscriptionId]) REFERENCES [dbo].[Subscription] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_Migration_DestinationSubscriptionId_INCL]
    ON [dbo].[Migration]([DestinationSubscriptionId] ASC)
    INCLUDE([RelationshipMigrationTypeId], [MigrationTimingOptionId], [EarningOptionId]) WITH (FILLFACTOR = 100);


GO

CREATE NONCLUSTERED INDEX [IX_Migration_SourceSubscriptionId_INCL]
    ON [dbo].[Migration]([SourceSubscriptionId] ASC)
    INCLUDE([RelationshipMigrationTypeId], [MigrationTimingOptionId], [EarningOptionId]) WITH (FILLFACTOR = 100);


GO

CREATE NONCLUSTERED INDEX [FKIX_Migration_RelationshipId]
    ON [dbo].[Migration]([RelationshipId] ASC) WITH (FILLFACTOR = 100);


GO

