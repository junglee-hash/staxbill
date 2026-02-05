CREATE TABLE [dbo].[TaxRule] (
    [Id]                   BIGINT          IDENTITY (1, 1) NOT NULL,
    [AccountId]            BIGINT          NOT NULL,
    [Percentage]           DECIMAL (10, 8) NOT NULL,
    [Name]                 NVARCHAR (60)   NOT NULL,
    [Description]          NVARCHAR (250)  NOT NULL,
    [CountryId]            BIGINT          NULL,
    [StateId]              BIGINT          NULL,
    [RegistrationCode]     NVARCHAR (100)  NULL,
    [CreatedTimestamp]     DATETIME        NOT NULL,
    [StartDate]            DATETIME        NULL,
    [EndDate]              DATETIME        NULL,
    [QuickBooksTaxCodeId]  BIGINT          NULL,
    [QuickBooksTaxRateId]  BIGINT          NULL,
    [TaxCode]              NVARCHAR (1000) NOT NULL,
    [IsRetired]            BIT             CONSTRAINT [DF_IsRetired] DEFAULT ((0)) NOT NULL,
    [AuditStatusId]        INT             CONSTRAINT [DF_AuditStatusId] DEFAULT ((1)) NOT NULL,
    [SalesTrackingCodeId1] BIGINT          NULL,
    [SalesTrackingCodeId2] BIGINT          NULL,
    [SalesTrackingCodeId3] BIGINT          NULL,
    [SalesTrackingCodeId4] BIGINT          NULL,
    [SalesTrackingCodeId5] BIGINT          NULL,
    CONSTRAINT [pk_TaxRule] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [fk_Country_CountryId] FOREIGN KEY ([CountryId]) REFERENCES [Lookup].[Country] ([Id]),
    CONSTRAINT [fk_Country_StateId] FOREIGN KEY ([StateId]) REFERENCES [Lookup].[State] ([Id]),
    CONSTRAINT [fk_TaxRule_AccountId] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id]),
    CONSTRAINT [fk_TaxRule_SalesTrackingCodeId1] FOREIGN KEY ([SalesTrackingCodeId1]) REFERENCES [dbo].[SalesTrackingCode] ([Id]),
    CONSTRAINT [fk_TaxRule_SalesTrackingCodeId2] FOREIGN KEY ([SalesTrackingCodeId2]) REFERENCES [dbo].[SalesTrackingCode] ([Id]),
    CONSTRAINT [fk_TaxRule_SalesTrackingCodeId3] FOREIGN KEY ([SalesTrackingCodeId3]) REFERENCES [dbo].[SalesTrackingCode] ([Id]),
    CONSTRAINT [fk_TaxRule_SalesTrackingCodeId4] FOREIGN KEY ([SalesTrackingCodeId4]) REFERENCES [dbo].[SalesTrackingCode] ([Id]),
    CONSTRAINT [fk_TaxRule_SalesTrackingCodeId5] FOREIGN KEY ([SalesTrackingCodeId5]) REFERENCES [dbo].[SalesTrackingCode] ([Id]),
    CONSTRAINT [UK_TaxRule] UNIQUE NONCLUSTERED ([AccountId] ASC, [Name] ASC, [Description] ASC, [Percentage] ASC, [CountryId] ASC, [StateId] ASC, [StartDate] ASC, [EndDate] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON)
);


GO

CREATE NONCLUSTERED INDEX [IX_TaxRule_CountryId]
    ON [dbo].[TaxRule]([CountryId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_TaxRule_StateId]
    ON [dbo].[TaxRule]([StateId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [COVIX_TaxRule_AccountId_All]
    ON [dbo].[TaxRule]([AccountId] ASC)
    INCLUDE([Id], [Percentage], [Name], [Description], [CountryId], [StateId], [RegistrationCode], [CreatedTimestamp], [StartDate], [EndDate], [QuickBooksTaxCodeId], [QuickBooksTaxRateId], [TaxCode], [IsRetired], [AuditStatusId], [SalesTrackingCodeId1], [SalesTrackingCodeId2], [SalesTrackingCodeId3], [SalesTrackingCodeId4], [SalesTrackingCodeId5]);


GO

