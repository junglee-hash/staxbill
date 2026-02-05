CREATE TABLE [dbo].[HostedPagePlanFamilyRelationship] (
    [Id]                       BIGINT          IDENTITY (1, 1) NOT NULL,
    [HostedPageId]             BIGINT          NOT NULL,
    [PlanFamilyRelationshipId] BIGINT          NOT NULL,
    [TitleHeight]              INT             NOT NULL,
    [TitleText]                NVARCHAR (500)  NOT NULL,
    [DescriptionHeight]        INT             NOT NULL,
    [DescriptionText]          NVARCHAR (2000) NULL,
    [ButtonText]               NVARCHAR (255)  NOT NULL,
    [MigrationTimingId]        TINYINT         CONSTRAINT [hppfr_MigrationTimingId] DEFAULT ((1)) NOT NULL,
    [RequirePaymentMethod]     BIT             CONSTRAINT [hppfr_RequirePaymentMethod] DEFAULT ((0)) NOT NULL,
    [AvailableOnSSP]           BIT             CONSTRAINT [df_HostedPagePlanFamilyRelationship_AvailableOnSSP] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_HostedPagePlanFamilyRelationship] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_HostedPagePlanFamilyRelationship_HostedPage] FOREIGN KEY ([HostedPageId]) REFERENCES [dbo].[HostedPage] ([Id]),
    CONSTRAINT [FK_HostedPagePlanFamilyRelationship_HostedPageMigrationTiming] FOREIGN KEY ([MigrationTimingId]) REFERENCES [Lookup].[HostedPageMigrationTiming] ([Id]),
    CONSTRAINT [FK_HostedPagePlanFamilyRelationship_PlanFamilyRelationship] FOREIGN KEY ([PlanFamilyRelationshipId]) REFERENCES [dbo].[PlanFamilyRelationship] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_HostedPagePlanFamilyRelationship_HostedPageId]
    ON [dbo].[HostedPagePlanFamilyRelationship]([HostedPageId] ASC) WITH (FILLFACTOR = 100);


GO

