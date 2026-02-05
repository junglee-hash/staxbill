CREATE TABLE [dbo].[AvalaraConfiguration] (
    [Id]                             BIGINT         NOT NULL,
    [Enabled]                        BIT            NOT NULL,
    [AccountNumber]                  NVARCHAR (255) NOT NULL,
    [LicenseKey]                     NVARCHAR (255) NOT NULL,
    [OrganizationCode]               NVARCHAR (255) NULL,
    [DevMode]                        BIT            NOT NULL,
    [Line1]                          NVARCHAR (255) NULL,
    [Line2]                          NVARCHAR (255) NULL,
    [CountryId]                      BIGINT         NULL,
    [StateId]                        BIGINT         NULL,
    [City]                           NVARCHAR (50)  NULL,
    [PostalZip]                      NVARCHAR (10)  NULL,
    [Salt]                           NVARCHAR (32)  NOT NULL,
    [CommitTaxes]                    BIT            NOT NULL,
    [NexusOption]                    INT            CONSTRAINT [DF_NexusOption] DEFAULT ((1)) NOT NULL,
    [CompanyId]                      BIGINT         NULL,
    [ExemptionCertificateManagement] BIT            CONSTRAINT [DF_ExemptionCertificateManagement] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_AvalaraConfiguration] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_AvalaraConfiguration_Account] FOREIGN KEY ([Id]) REFERENCES [dbo].[Account] ([Id]),
    CONSTRAINT [FK_AvalaraConfiguration_AvalaraNexusOption] FOREIGN KEY ([NexusOption]) REFERENCES [Lookup].[AvalaraNexusOption] ([Id]),
    CONSTRAINT [FK_AvalaraConfiguration_Country] FOREIGN KEY ([CountryId]) REFERENCES [Lookup].[Country] ([Id]),
    CONSTRAINT [FK_AvalaraConfiguration_State] FOREIGN KEY ([StateId]) REFERENCES [Lookup].[State] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_AvalaraConfiguration_CountryId]
    ON [dbo].[AvalaraConfiguration]([CountryId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_AvalaraConfiguration_StateId]
    ON [dbo].[AvalaraConfiguration]([StateId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

