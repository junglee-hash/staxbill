CREATE TABLE [dbo].[PlanFamilyRelationship] (
    [Id]                          BIGINT          IDENTITY (1, 1) NOT NULL,
    [PlanFamilyId]                BIGINT          NOT NULL,
    [SourcePlanFrequencyId]       BIGINT          NOT NULL,
    [DestinationPlanFrequencyId]  BIGINT          NOT NULL,
    [RelationshipMigrationTypeId] INT             NOT NULL,
    [SourceLabel]                 NVARCHAR (255)  NOT NULL,
    [DestinationLabel]            NVARCHAR (255)  NOT NULL,
    [EarningOptionId]             INT             NOT NULL,
    [NameOverrideOptionId]        INT             NOT NULL,
    [DescriptionOverrideOptionId] INT             NOT NULL,
    [ReferenceOptionId]           INT             NOT NULL,
    [ExpiryOptionId]              INT             NOT NULL,
    [ContractStartOptionId]       INT             NOT NULL,
    [ContractEndOptionId]         INT             NOT NULL,
    [ModifiedTimestamp]           DATETIME        CONSTRAINT [DF_modifiedtimestamp] DEFAULT (getutcdate()) NOT NULL,
    [CreatedTimestamp]            DATETIME        CONSTRAINT [DF_createdtimestamp] DEFAULT (getutcdate()) NOT NULL,
    [CustomFieldsOptionId]        INT             NOT NULL,
    [PlanStatusId]                INT             CONSTRAINT [DF_PlanStatusId] DEFAULT ((1)) NOT NULL,
    [CouponCodeId]                BIGINT          NULL,
    [Name]                        NVARCHAR (255)  NULL,
    [Description]                 NVARCHAR (1000) NULL,
    CONSTRAINT [PK_PlanFamilyRelationship] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_PlanFamilyRelationship_ContractEndOptionId] FOREIGN KEY ([ContractEndOptionId]) REFERENCES [Lookup].[PlanFamilyMigrationOptions] ([Id]),
    CONSTRAINT [FK_PlanFamilyRelationship_ContractStartOptionId] FOREIGN KEY ([ContractStartOptionId]) REFERENCES [Lookup].[PlanFamilyMigrationOptions] ([Id]),
    CONSTRAINT [FK_PlanFamilyRelationship_CouponCode] FOREIGN KEY ([CouponCodeId]) REFERENCES [dbo].[CouponCode] ([Id]),
    CONSTRAINT [FK_PlanFamilyRelationship_CustomFieldsOptionId] FOREIGN KEY ([CustomFieldsOptionId]) REFERENCES [Lookup].[PlanFamilyMigrationOptions] ([Id]),
    CONSTRAINT [FK_PlanFamilyRelationship_DescriptionOverrideOptionId] FOREIGN KEY ([DescriptionOverrideOptionId]) REFERENCES [Lookup].[PlanFamilyMigrationOptions] ([Id]),
    CONSTRAINT [FK_PlanFamilyRelationship_DestinationPlanFrequencyId] FOREIGN KEY ([DestinationPlanFrequencyId]) REFERENCES [dbo].[PlanFrequency] ([Id]),
    CONSTRAINT [FK_PlanFamilyRelationship_EarningOptionId] FOREIGN KEY ([EarningOptionId]) REFERENCES [Lookup].[SubscriptionCancellationReversalOptions] ([Id]),
    CONSTRAINT [FK_PlanFamilyRelationship_ExpiryOptionId] FOREIGN KEY ([ExpiryOptionId]) REFERENCES [Lookup].[PlanFamilyMigrationOptions] ([Id]),
    CONSTRAINT [FK_PlanFamilyRelationship_NameOverrideOptionId] FOREIGN KEY ([NameOverrideOptionId]) REFERENCES [Lookup].[PlanFamilyMigrationOptions] ([Id]),
    CONSTRAINT [FK_PlanFamilyRelationship_PlanFamilyId] FOREIGN KEY ([PlanFamilyId]) REFERENCES [dbo].[PlanFamily] ([Id]),
    CONSTRAINT [FK_PlanFamilyRelationship_ReferenceOptionId] FOREIGN KEY ([ReferenceOptionId]) REFERENCES [Lookup].[PlanFamilyMigrationOptions] ([Id]),
    CONSTRAINT [FK_PlanFamilyRelationship_RelationshipMigrationTypeId] FOREIGN KEY ([RelationshipMigrationTypeId]) REFERENCES [Lookup].[RelationshipMigrationType] ([Id]),
    CONSTRAINT [FK_PlanFamilyRelationship_SourcePlanFrequencyId] FOREIGN KEY ([SourcePlanFrequencyId]) REFERENCES [dbo].[PlanFrequency] ([Id]) ON DELETE CASCADE
);


GO

CREATE NONCLUSTERED INDEX [FKIX_PlanFamilyRelationship_PlanFamilyId]
    ON [dbo].[PlanFamilyRelationship]([PlanFamilyId] ASC) WITH (FILLFACTOR = 100);


GO

