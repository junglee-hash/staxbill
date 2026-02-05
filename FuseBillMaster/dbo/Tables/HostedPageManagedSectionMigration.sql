CREATE TABLE [dbo].[HostedPageManagedSectionMigration] (
    [Id]                                   BIGINT          IDENTITY (1, 1) NOT NULL,
    [HostedPageManagedSelfServicePortalId] BIGINT          NOT NULL,
    [PlanFamilyRelationshipId]             BIGINT          NOT NULL,
    [TitleHeight]                          INT             NOT NULL,
    [TitleText]                            NVARCHAR (500)  NOT NULL,
    [DescriptionHeight]                    INT             NOT NULL,
    [DescriptionText]                      NVARCHAR (2000) NULL,
    [ButtonText]                           NVARCHAR (255)  NOT NULL,
    [MigrationTimingId]                    TINYINT         CONSTRAINT [hpmsm_MigrationTimingId] DEFAULT ((1)) NOT NULL,
    [RequirePaymentMethod]                 BIT             CONSTRAINT [hpmsm_RequirePaymentMethod] DEFAULT ((0)) NOT NULL,
    [AvailableOnSSP]                       BIT             CONSTRAINT [df_HostedPageManagedSectionMigration_AvailableOnSSP] DEFAULT ((0)) NOT NULL,
    [SortOrder]                            INT             NULL,
    CONSTRAINT [PK_HostedPageManagedSectionMigration] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_HostedPageManagedSectionMigration_HostedPageManagedSelfServicePortal] FOREIGN KEY ([HostedPageManagedSelfServicePortalId]) REFERENCES [dbo].[HostedPageManagedSelfServicePortal] ([Id]),
    CONSTRAINT [FK_HostedPageManagedSectionMigration_HostedPageMigrationTiming] FOREIGN KEY ([MigrationTimingId]) REFERENCES [Lookup].[HostedPageMigrationTiming] ([Id]),
    CONSTRAINT [FK_HostedPageManagedSectionMigration_PlanFamilyRelationship] FOREIGN KEY ([PlanFamilyRelationshipId]) REFERENCES [dbo].[PlanFamilyRelationship] ([Id]) ON DELETE CASCADE
);


GO

CREATE NONCLUSTERED INDEX [IX_HostedPageManagedSectionMigration_HostedPageManagedSelfServicePortalId]
    ON [dbo].[HostedPageManagedSectionMigration]([HostedPageManagedSelfServicePortalId] ASC) WITH (FILLFACTOR = 100);


GO

