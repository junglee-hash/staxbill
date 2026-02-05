CREATE TABLE [dbo].[PlanFamily] (
    [Id]                          BIGINT          IDENTITY (1, 1) NOT NULL,
    [AccountId]                   BIGINT          NOT NULL,
    [ModifiedTimestamp]           DATETIME        NOT NULL,
    [CreatedTimestamp]            DATETIME        NOT NULL,
    [Code]                        NVARCHAR (255)  NOT NULL,
    [Name]                        NVARCHAR (100)  NOT NULL,
    [Description]                 NVARCHAR (1000) NULL,
    [EarningOptionId]             INT             NOT NULL,
    [NameOverrideOptionId]        INT             NOT NULL,
    [DescriptionOverrideOptionId] INT             NOT NULL,
    [ReferenceOptionId]           INT             NOT NULL,
    [ExpiryOptionId]              INT             NOT NULL,
    [ContractStartOptionId]       INT             NOT NULL,
    [ContractEndOptionId]         INT             NOT NULL,
    [CustomFieldsOptionId]        INT             CONSTRAINT [DF_PlanFamily_CustomFields] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_PlanFamily] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_PlanFamily_AccountId] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id]),
    CONSTRAINT [FK_PlanFamily_ContractEndOptionId] FOREIGN KEY ([ContractEndOptionId]) REFERENCES [Lookup].[PlanFamilyMigrationOptions] ([Id]),
    CONSTRAINT [FK_PlanFamily_ContractStartOptionId] FOREIGN KEY ([ContractStartOptionId]) REFERENCES [Lookup].[PlanFamilyMigrationOptions] ([Id]),
    CONSTRAINT [FK_PlanFamily_CustomFieldsOptionId] FOREIGN KEY ([CustomFieldsOptionId]) REFERENCES [Lookup].[PlanFamilyMigrationOptions] ([Id]),
    CONSTRAINT [FK_PlanFamily_DescriptionOverrideOptionId] FOREIGN KEY ([DescriptionOverrideOptionId]) REFERENCES [Lookup].[PlanFamilyMigrationOptions] ([Id]),
    CONSTRAINT [FK_PlanFamily_EarningOptionId] FOREIGN KEY ([EarningOptionId]) REFERENCES [Lookup].[SubscriptionCancellationReversalOptions] ([Id]),
    CONSTRAINT [FK_PlanFamily_ExpiryOptionId] FOREIGN KEY ([ExpiryOptionId]) REFERENCES [Lookup].[PlanFamilyMigrationOptions] ([Id]),
    CONSTRAINT [FK_PlanFamily_NameOverrideOptionId] FOREIGN KEY ([NameOverrideOptionId]) REFERENCES [Lookup].[PlanFamilyMigrationOptions] ([Id]),
    CONSTRAINT [FK_PlanFamily_ReferenceOptionId] FOREIGN KEY ([ReferenceOptionId]) REFERENCES [Lookup].[PlanFamilyMigrationOptions] ([Id]),
    CONSTRAINT [uc_PlanFamily_AccountId_Code] UNIQUE NONCLUSTERED ([AccountId] ASC, [Code] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON)
);


GO

