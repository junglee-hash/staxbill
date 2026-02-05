CREATE TABLE [dbo].[AvalaraConfigurationBySalesTrackingCode] (
    [Id]                     BIGINT         IDENTITY (1, 1) NOT NULL,
    [AvalaraConfigurationId] BIGINT         NOT NULL,
    [CreatedTimestamp]       DATETIME       NOT NULL,
    [ModifiedTimestamp]      DATETIME       NOT NULL,
    [OrganizationCode]       NVARCHAR (255) NOT NULL,
    [SalesTrackingCode1Id]   BIGINT         NULL,
    [SalesTrackingCode2Id]   BIGINT         NULL,
    [SalesTrackingCode3Id]   BIGINT         NULL,
    [SalesTrackingCode4Id]   BIGINT         NULL,
    [SalesTrackingCode5Id]   BIGINT         NULL,
    [Priority]               INT            NOT NULL,
    [CompanyId]              BIGINT         NULL,
    CONSTRAINT [PK_AvalaraConfigurationBySalesTrackingCode] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_AvalaraConfigurationBySalesTrackingCode_AvalaraConfiguration] FOREIGN KEY ([AvalaraConfigurationId]) REFERENCES [dbo].[AvalaraConfiguration] ([Id]),
    CONSTRAINT [FK_AvalaraConfigurationBySalesTrackingCode_SalesTrackingCode1] FOREIGN KEY ([SalesTrackingCode1Id]) REFERENCES [dbo].[SalesTrackingCode] ([Id]),
    CONSTRAINT [FK_AvalaraConfigurationBySalesTrackingCode_SalesTrackingCode2] FOREIGN KEY ([SalesTrackingCode2Id]) REFERENCES [dbo].[SalesTrackingCode] ([Id]),
    CONSTRAINT [FK_AvalaraConfigurationBySalesTrackingCode_SalesTrackingCode3] FOREIGN KEY ([SalesTrackingCode3Id]) REFERENCES [dbo].[SalesTrackingCode] ([Id]),
    CONSTRAINT [FK_AvalaraConfigurationBySalesTrackingCode_SalesTrackingCode4] FOREIGN KEY ([SalesTrackingCode4Id]) REFERENCES [dbo].[SalesTrackingCode] ([Id]),
    CONSTRAINT [FK_AvalaraConfigurationBySalesTrackingCode_SalesTrackingCode5] FOREIGN KEY ([SalesTrackingCode5Id]) REFERENCES [dbo].[SalesTrackingCode] ([Id])
);


GO

